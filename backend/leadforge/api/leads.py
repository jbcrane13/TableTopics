"""Lead API routes"""
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from leadforge.models.lead import Lead, LeadStatus
from leadforge.db.database import get_db
from leadforge.db.repository import LeadRepository

router = APIRouter(prefix="/api/leads", tags=["leads"])


class LeadSearchRequest:
    """Request body for lead search"""
    city: str
    project_types: List[str]


@router.post("/search", response_model=List[Lead])
async def search_leads(
    city: str,
    project_types: List[str] = Query(default=[]),
    db: AsyncSession = Depends(get_db),
):
    """
    Search leads by city and project types.
    Returns leads matching all specified criteria.
    """
    repo = LeadRepository(db)
    
    # Search by city (project_types not fully implemented yet)
    leads = await repo.list(city=city, limit=100)
    
    # Convert to Pydantic models
    return [Lead.model_validate(lead) for lead in leads]


@router.get("", response_model=dict)
async def list_leads(
    city: Optional[str] = Query(None),
    project_type: Optional[str] = Query(None),
    status: Optional[LeadStatus] = Query(None),
    min_score: Optional[float] = Query(None, ge=0.0, le=1.0),
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
):
    """
    List leads with optional filtering.
    Supports filtering by city, project type, status, and minimum score.
    """
    repo = LeadRepository(db)
    
    leads = await repo.list(
        city=city,
        project_type=project_type,
        status=status,
        min_score=min_score,
        limit=limit,
        offset=offset,
    )
    
    total = await repo.count(
        city=city,
        project_type=project_type,
        status=status,
        min_score=min_score,
    )
    
    return {
        "leads": [Lead.model_validate(lead) for lead in leads],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.get("/{lead_id}", response_model=Lead)
async def get_lead(
    lead_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get a single lead by ID.
    """
    repo = LeadRepository(db)
    lead = await repo.get(lead_id)
    
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    return Lead.model_validate(lead)


@router.post("", response_model=Lead)
async def create_lead(
    lead: Lead,
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new lead.
    """
    repo = LeadRepository(db)
    db_lead = await repo.create(lead)
    return Lead.model_validate(db_lead)


@router.put("/{lead_id}", response_model=Lead)
async def update_lead(
    lead_id: str,
    lead: Lead,
    db: AsyncSession = Depends(get_db),
):
    """
    Update an existing lead.
    """
    repo = LeadRepository(db)
    
    # Convert Lead to dict for update
    update_data = lead.model_dump(exclude_unset=True)
    db_lead = await repo.update(lead_id, **update_data)
    
    if not db_lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    return Lead.model_validate(db_lead)


@router.delete("/{lead_id}")
async def delete_lead(
    lead_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a lead.
    """
    repo = LeadRepository(db)
    success = await repo.delete(lead_id)
    
    if not success:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    return {"status": "deleted", "id": lead_id}
