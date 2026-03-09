"""Orchestrator - Coordinates agent pipeline"""
from typing import List, Dict, Any
from loguru import logger

from leadforge.agents.permit_scout import PermitScoutAgent
from leadforge.agents.enrichment import EnrichmentAgent
from leadforge.agents.qualification import QualificationAgent
from leadforge.agents.prioritization import PrioritizationAgent
from leadforge.db.repository import LeadRepository
from leadforge.models.lead import LeadStatus


class Orchestrator:
    """Coordinates the agent pipeline"""
    
    def __init__(self, repo: LeadRepository):
        self.repo = repo
        self.scout = PermitScoutAgent()
        self.enrichment = EnrichmentAgent()
        self.qualification = QualificationAgent()
        self.prioritization = PrioritizationAgent()
    
    async def run_pipeline(
        self,
        city: str,
        state: str,
        min_value: int = 50000,
        days_ago: int = 90,
    ) -> Dict[str, Any]:
        """
        Run the full agent pipeline.
        
        1. PermitScout: Find new permits
        2. Enrichment: Find decision makers
        3. Qualification: Validate contractors
        4. Prioritization: Score and rank
        
        Args:
            city: City to search
            state: State code
            min_value: Minimum project value
            days_ago: Days to look back
        
        Returns:
            Summary of pipeline run
        """
        logger.info(f"Orchestrator: Starting pipeline for {city}, {state}")
        
        # Step 1: Find permits
        new_leads = await self.scout.run(
            repo=self.repo,
            city=city,
            state=state,
            min_value=min_value,
            days_ago=days_ago,
        )
        
        if not new_leads:
            return {
                "status": "complete",
                "leads_found": 0,
                "enriched": 0,
                "qualified": 0,
                "hot_leads": 0,
            }
        
        # Step 2: Enrich each lead
        enriched_count = 0
        for lead in new_leads:
            dm_info = await self.enrichment.enrich_lead(lead.id, self.repo)
            if dm_info and dm_info.get("name"):
                enriched_count += 1
        
        # Step 3: Qualify each lead
        qualified_count = 0
        for lead in new_leads:
            metrics = await self.qualification.qualify_lead(lead.id, self.repo)
            if metrics and metrics.get("projects_completed"):
                qualified_count += 1
        
        # Step 4: Prioritize and update status
        # Re-fetch leads with updated data
        all_leads = await self.repo.list(limit=100)
        scored_leads = await self.prioritization.prioritize_leads(all_leads)
        
        # Update lead scores and statuses
        hot_count = 0
        for lead_data in scored_leads:
            await self.repo.update(
                lead_data["id"],
                score=lead_data["score"],
            )
            
            # Update status based on tier
            tier = lead_data["tier"]
            if tier == "hot":
                await self.repo.update(lead_data["id"], status=LeadStatus.HOT)
                hot_count += 1
        
        logger.info(f"Orchestrator: Pipeline complete. Hot leads: {hot_count}")
        
        return {
            "status": "complete",
            "leads_found": len(new_leads),
            "enriched": enriched_count,
            "qualified": qualified_count,
            "hot_leads": hot_count,
        }
