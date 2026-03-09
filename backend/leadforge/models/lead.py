"""Lead data models"""
from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field


class LeadStatus(str, Enum):
    PENDING = "pending"
    ENRICHED = "enriched"
    QUALIFIED = "qualified"
    HOT = "hot"
    CONTACTED = "contacted"
    DISMISSED = "dismissed"


class Lead(BaseModel):
    """A sales lead"""
    id: str = Field(..., description="Unique lead ID")
    permit_id: str = Field(..., description="Shovels permit ID")
    
    # Location
    city: str
    state: str
    zip_code: Optional[str] = None
    
    # Project
    project_type: str  # hotel, restaurant, etc.
    project_value: Optional[int] = None
    permit_date: datetime
    
    # Contractor
    contractor_name: str
    contractor_id: Optional[str] = None
    
    # Scoring
    score: float = Field(0.0, ge=0.0, le=1.0)
    status: LeadStatus = LeadStatus.PENDING
    
    # Enrichment
    decision_maker_name: Optional[str] = None
    decision_maker_title: Optional[str] = None
    decision_maker_email: Optional[str] = None
    decision_maker_phone: Optional[str] = None
    
    # Qualification
    contractor_projects_completed: Optional[int] = None
    contractor_rating: Optional[float] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
