import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings

logger = logging.getLogger("app.database")

Base = declarative_base()

# Use SQLite for local tests or PostgreSQL for staging/prod
connect_args = {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}

engine = create_engine(
    settings.database_url,
    connect_args=connect_args,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    try:
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables verified/initialized.")
    except Exception as e:
        logger.warning(f"Database initialization warning: {e}")

# Call init_db on module import so tables exist
init_db()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_db_connection() -> bool:
    try:
        with engine.connect() as connection:
            return True
    except Exception as e:
        logger.warning(f"Database health check warning: {e}")
        return False
