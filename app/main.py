import time
import uuid
import logging
import json
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI, Depends, Request, Response, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.config import settings
from app.database import Base, engine, get_db, check_db_connection
from app.models import ItemDB, ItemCreate, ItemResponse

# ---------------------------------------------------------------------------------------------------------------------
# STRUCTURED JSON LOGGING SETUP
# ---------------------------------------------------------------------------------------------------------------------
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if hasattr(record, "request_id"):
            log_entry["request_id"] = record.request_id
        if hasattr(record, "latency_ms"):
            log_entry["latency_ms"] = record.latency_ms
        if hasattr(record, "status_code"):
            log_entry["status_code"] = record.status_code
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_entry)

logger = logging.getLogger("app")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.handlers = [handler]
logger.propagate = False

# ---------------------------------------------------------------------------------------------------------------------
# IN-MEMORY METRICS STORE (For lightweight platform observability)
# ---------------------------------------------------------------------------------------------------------------------
START_TIME = time.time()
METRICS = {
    "total_requests": 0,
    "requests_2xx": 0,
    "requests_4xx": 0,
    "requests_5xx": 0,
    "total_latency_ms": 0.0,
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LIFECYCLE (Startup & Graceful Shutdown)
# ---------------------------------------------------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION} in environment: {settings.ENVIRONMENT}")
    try:
        # Create tables if not exist
        Base.metadata.create_all(bind=engine)
        logger.info("Database schema initialized successfully.")
    except Exception as e:
        logger.warning(f"Database schema initialization warning (will retry on demand): {e}")
    yield
    logger.info(f"Shutting down {settings.APP_NAME} gracefully.")

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="8Byte.ai DevOps Engineer Assignment Production Microservice",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------------------------------------------------
# REQUEST TIMING & LOGGING MIDDLEWARE
# ---------------------------------------------------------------------------------------------------------------------
@app.middleware("http")
async def log_and_measure_requests(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    start_time = time.time()
    
    response = await call_next(request)
    
    latency_ms = round((time.time() - start_time) * 1000, 2)
    response.headers["x-request-id"] = request_id
    response.headers["x-response-time-ms"] = str(latency_ms)
    
    # Update metrics
    METRICS["total_requests"] += 1
    METRICS["total_latency_ms"] += latency_ms
    
    if 200 <= response.status_code < 400:
        METRICS["requests_2xx"] += 1
    elif 400 <= response.status_code < 500:
        METRICS["requests_4xx"] += 1
    elif response.status_code >= 500:
        METRICS["requests_5xx"] += 1
        
    extra = {
        "request_id": request_id,
        "latency_ms": latency_ms,
        "status_code": response.status_code
    }
    logger.info(f"{request.method} {request.url.path} -> {response.status_code} ({latency_ms}ms)", extra=extra)
    return response

# ---------------------------------------------------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------------
@app.get("/", tags=["General"])
def read_root():
    """Service landing endpoint with operational metadata."""
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "status": "healthy",
        "docs": "/docs"
    }

@app.get("/health", tags=["Observability"])
def health_check():
    """Liveness & Readiness probe used by ALB Target Group."""
    db_ok = check_db_connection()
    uptime_sec = round(time.time() - START_TIME, 2)
    
    status_code = status.HTTP_200_OK
    return JSONResponse(
        status_code=status_code,
        content={
            "status": "healthy",
            "uptime_seconds": uptime_sec,
            "database": "connected" if db_ok else "degraded/disconnected",
            "environment": settings.ENVIRONMENT,
            "version": settings.APP_VERSION,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    )

@app.get("/api/v1/metrics", tags=["Observability"])
def get_metrics():
    """Lightweight operational and performance metrics endpoint."""
    uptime_sec = max(round(time.time() - START_TIME, 2), 0.001)
    total_req = METRICS["total_requests"]
    avg_latency = round(METRICS["total_latency_ms"] / total_req, 2) if total_req > 0 else 0.0
    req_per_sec = round(total_req / uptime_sec, 2)
    error_rate_pct = round((METRICS["requests_5xx"] / total_req) * 100, 2) if total_req > 0 else 0.0

    return {
        "uptime_seconds": uptime_sec,
        "total_requests": total_req,
        "requests_per_second": req_per_sec,
        "average_latency_ms": avg_latency,
        "error_rate_percent": error_rate_pct,
        "status_breakdown": {
            "2xx": METRICS["requests_2xx"],
            "4xx": METRICS["requests_4xx"],
            "5xx": METRICS["requests_5xx"]
        }
    }

@app.get("/api/v1/items", response_model=list[ItemResponse], tags=["Items"])
def list_items(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    """Retrieve items from PostgreSQL database."""
    items = db.query(ItemDB).offset(skip).limit(limit).all()
    return items

@app.post("/api/v1/items", response_model=ItemResponse, status_code=status.HTTP_201_CREATED, tags=["Items"])
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    """Create a new item in PostgreSQL database."""
    db_item = ItemDB(title=item.title, description=item.description)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    logger.info(f"Created new item with ID: {db_item.id}")
    return db_item
