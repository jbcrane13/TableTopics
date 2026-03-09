"""Contractor model"""
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class Contractor(BaseModel):
    """A construction contractor"""
    id: str
    name: str
    license_number: Optional[str] = None
    
    # Contact
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    
    # Business
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    
    # Performance
    projects_count: Optional[int] = None
    rating: Optional[float] = None
    years_in_business: Optional[int] = None
    
    # Employees (decision makers)
    employees: List[dict] = []
    
    created_at: datetime = datetime.utcnow()
