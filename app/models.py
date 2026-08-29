from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, DateTime, Text
from pydantic import BaseModel, Field, ConfigDict
from app.database import Base


def utc_now():
    return datetime.now(timezone.utc)


# SQLAlchemy Database Model
class ItemDB(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime, default=utc_now)


# Pydantic Schemas for API validation
class ItemCreate(BaseModel):
    title: str = Field(
        ...,
        min_length=1,
        max_length=255,
        json_schema_extra={"example": "Sample DevOps Task"},
    )
    description: str | None = Field(
        None,
        max_length=1000,
        json_schema_extra={"example": "Automate infrastructure using Terraform"},
    )


class ItemResponse(BaseModel):
    id: int
    title: str
    description: str | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
