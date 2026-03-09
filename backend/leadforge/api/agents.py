"""Agent API routes"""
from fastapi import APIRouter, Depends, BackgroundTasks, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from typing import List, Optional

from leadforge.db.database import get_db
from leadforge.db.repository import LeadRepository
from leadforge.agents.permit_scout import PermitScoutAgent
from leadforge.agents.enrichment import EnrichmentAgent
from leadforge.models.lead import Lead

router = APIRouter(prefix="/api/agents", tags=["agents"])


class ScoutRequest(BaseModel):
    """Request to run PermitScout agent"""
    city: str
    state: str
    min_value: int = 50000
    days_ago: int = 90


class EnrichRequest(BaseModel):
    """Request to run Enrichment agent"""
    lead_ids: Optional[List[str]] = None
    status_filter: Optional[str] = None  # "pending" or "all"


class AgentResponse(BaseModel):
    """Generic agent response"""
    status: str
    message: str
    details: dict = {}


@router.post("/scout", response_model=AgentResponse)
async def run_scout(
    request: ScoutRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Run the PermitScout agent to find new leads.
    
    This searches for building permits and saves them to the database.
    """
    repo = LeadRepository(db)
    scout = PermitScoutAgent()
    
    try:
        new_leads = await scout.run(
            repo=repo,
            city=request.city,
            state=request.state,
            min_value=request.min_value,
            days_ago=request.days_ago,
        )
        
        return AgentResponse(
            status="success",
            message=f"Found {len(new_leads)} new leads in {request.city}, {request.state}",
            details={
                "leads_created": len(new_leads),
                "city": request.city,
                "state": request.state,
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/enrich", response_model=AgentResponse)
async def run_enrichment(
    request: EnrichRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Run the Enrichment agent to find decision maker contacts.
    
    Args:
        lead_ids: Specific leads to enrich (optional)
        status_filter: Enrich all leads with this status (optional)
    
    If neither provided, enriches all PENDING leads.
    """
    repo = LeadRepository(db)
    enrichment = EnrichmentAgent()
    
    # Determine which leads to enrich
    if request.lead_ids:
        lead_ids = request.lead_ids
    elif request.status_filter:
        from leadforge.models.lead import LeadStatus
        status = LeadStatus(request.status_filter)
        leads = await repo.list(status=status, limit=100)
        lead_ids = [l.id for l in leads]
    else:
        # Default: enrich all PENDING leads
        from leadforge.models.lead import LeadStatus
        leads = await repo.list(status=LeadStatus.PENDING, limit=100)
        lead_ids = [l.id for l in leads]
    
    if not lead_ids:
        return AgentResponse(
            status="success",
            message="No leads to enrich",
            details={"enriched": 0}
        )
    
    try:
        result = await enrichment.batch_enrich(lead_ids, repo)
        
        return AgentResponse(
            status="success",
            message=f"Enriched {result['enriched']} leads",
            details=result
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/enrich/{lead_id}", response_model=dict)
async def enrich_single_lead(
    lead_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Enrich a single lead by ID.
    
    Returns the enrichment data found.
    """
    repo = LeadRepository(db)
    enrichment = EnrichmentAgent()
    
    try:
        result = await enrichment.enrich_lead(lead_id, repo)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def get_agent_status():
    """
    Get status of all agents.
    """
    return {
        "scout": {
            "status": "ready",
            "api_configured": True,  # TODO: Check Shovels API key
        },
        "enrichment": {
            "status": "ready",
            "apollo_configured": False,  # TODO: Check Apollo API key
        },
        "qualification": {
            "status": "ready",
            "buildzoom_configured": False,
        },
    }
