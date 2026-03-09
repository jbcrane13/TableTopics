"""SQLAlchemy ORM models"""
from datetime import datetime
from sqlalchemy import Column, String, Float, Integer, DateTime, Enum as SQLEnum, Text
from sqlalchemy.orm import relationship
from leadforge.db.database import Base
from leadforge.models.lead import LeadStatus


class LeadModel(Base):
    """SQLAlchemy model for leads table"""
    __tablename__ = "leads"

    id = Column(String, primary_key=True, index=True)
    permit_id = Column(String, index=True, nullable=False)
    
    # Location
    city = Column(String, index=True, nullable=False)
    state = Column(String(2), nullable=False)
    zip_code = Column(String(10), nullable=True)
    
    # Project
    project_type = Column(String, index=True, nullable=False)
    project_value = Column(Integer, nullable=True)
    permit_date = Column(DateTime, nullable=False)
    
    # Contractor
    contractor_name = Column(String, nullable=False)
    contractor_id = Column(String, nullable=True)
    
    # Scoring
    score = Column(Float, default=0.0, nullable=False)
    status = Column(SQLEnum(LeadStatus), default=LeadStatus.PENDING, nullable=False)
    
    # Enrichment
    decision_maker_name = Column(String, nullable=True)
    decision_maker_title = Column(String, nullable=True)
    decision_maker_email = Column(String, nullable=True)
    decision_maker_phone = Column(String, nullable=True)
    
    # Qualification
    contractor_projects_completed = Column(Integer, nullable=True)
    contractor_rating = Column(Float, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<Lead {self.id}: {self.contractor_name} - {self.city}>"
