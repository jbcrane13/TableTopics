"""Enrichment Agent - Finds decision maker contact info"""
from typing import Dict, Any, List, Optional
from loguru import logger
import httpx


class EnrichmentAgent:
    """Agent that enriches leads with decision maker contact information"""
    
    # TODO: Configure Apollo/PeopleDataLabs/LinkedIn APIs
    # For now, provides enrichment scaffolding
    
    def __init__(self, apollo_api_key: Optional[str] = None):
        self.apollo_api_key = apollo_api_key
        self.apollo_base_url = "https://api.apollo.io/v1"
    
    async def search_person(
        self,
        company_name: str,
        title_keywords: List[str] = ["owner", "ceo", "president", "principal", "partner", "director"],
    ) -> Dict[str, Any]:
        """
        Search for decision maker at a company.
        
        Uses Apollo API (if configured) or returns placeholder.
        
        Args:
            company_name: Name of the company
            title_keywords: Job titles to search for
        
        Returns:
            Dict with name, title, email, phone, confidence
        """
        if not self.apollo_api_key:
            # Placeholder enrichment - returns structured guess
            return await self._placeholder_enrichment(company_name)
        
        # Apollo API integration
        try:
            async with httpx.AsyncClient() as client:
                # Search for organization
                org_response = await client.post(
                    f"{self.apollo_base_url}/organizations/search",
                    headers={"Api-Key": self.apollo_api_key},
                    json={"q_organization_name": company_name},
                    timeout=30,
                )
                
                if org_response.status_code != 200:
                    logger.warning(f"Apollo org search failed: {org_response.status_code}")
                    return await self._placeholder_enrichment(company_name)
                
                org_data = org_response.json()
                organizations = org_data.get("organizations", [])
                
                if not organizations:
                    return await self._placeholder_enrichment(company_name)
                
                org_id = organizations[0].get("id")
                
                # Search for people at organization
                people_response = await client.post(
                    f"{self.apollo_base_url}/people/search",
                    headers={"Api-Key": self.apollo_api_key},
                    json={
                        "organization_ids": [org_id],
                        "person_titles": title_keywords,
                    },
                    timeout=30,
                )
                
                if people_response.status_code != 200:
                    logger.warning(f"Apollo people search failed: {people_response.status_code}")
                    return await self._placeholder_enrichment(company_name)
                
                people_data = people_response.json()
                people = people_data.get("people", [])
                
                if people:
                    # Return best match (first result)
                    person = people[0]
                    return {
                        "name": person.get("name"),
                        "title": person.get("title"),
                        "email": person.get("email"),
                        "phone": person.get("phone"),
                        "linkedin": person.get("linkedin_url"),
                        "confidence": 0.9 if person.get("email") else 0.5,
                    }
                
                return await self._placeholder_enrichment(company_name)
                
        except Exception as e:
            logger.error(f"Enrichment error: {e}")
            return await self._placeholder_enrichment(company_name)
    
    async def _placeholder_enrichment(self, company_name: str) -> Dict[str, Any]:
        """Return placeholder enrichment when API not available"""
        # In production, this would be replaced by real API calls
        return {
            "name": None,
            "title": None,
            "email": None,
            "phone": None,
            "confidence": 0.0,
        }
    
    async def enrich_lead(self, lead_id: str, repo) -> Dict[str, Any]:
        """
        Enrich a lead with decision maker info.
        
        Args:
            lead_id: ID of lead to enrich
            repo: LeadRepository instance
        
        Returns:
            Enrichment data
        """
        lead = await repo.get(lead_id)
        if not lead:
            logger.warning(f"Lead not found: {lead_id}")
            return {"error": "Lead not found"}
        
        # Skip if already enriched
        if lead.decision_maker_email or lead.decision_maker_phone:
            logger.info(f"Lead {lead_id} already enriched")
            return {
                "name": lead.decision_maker_name,
                "title": lead.decision_maker_title,
                "email": lead.decision_maker_email,
                "phone": lead.decision_maker_phone,
                "confidence": 0.95,  # Already enriched
            }
        
        # Search for decision maker
        dm_info = await self.search_person(
            company_name=lead.contractor_name,
            title_keywords=["owner", "ceo", "president", "principal", "partner", "director", "manager"],
        )
        
        if dm_info.get("name"):
            # Update lead with enrichment
            await repo.update(
                lead_id,
                decision_maker_name=dm_info["name"],
                decision_maker_title=dm_info.get("title"),
                decision_maker_email=dm_info.get("email"),
                decision_maker_phone=dm_info.get("phone"),
            )
            
            # Update status
            from leadforge.models.lead import LeadStatus
            if lead.status == LeadStatus.PENDING:
                await repo.update(lead_id, status=LeadStatus.ENRICHED)
            
            logger.info(f"Enriched lead {lead_id}: {dm_info['name']}")
        else:
            logger.info(f"No decision maker found for lead {lead_id}")
        
        return dm_info
    
    async def batch_enrich(
        self,
        lead_ids: List[str],
        repo,
        max_concurrent: int = 5,
    ) -> Dict[str, Any]:
        """
        Enrich multiple leads concurrently.
        
        Args:
            lead_ids: List of lead IDs to enrich
            repo: LeadRepository instance
            max_concurrent: Maximum concurrent enrichments
        
        Returns:
            Summary of enrichment results
        """
        import asyncio
        
        semaphore = asyncio.Semaphore(max_concurrent)
        
        async def enrich_with_semaphore(lead_id: str) -> Dict[str, Any]:
            async with semaphore:
                return await self.enrich_lead(lead_id, repo)
        
        results = await asyncio.gather(
            *[enrich_with_semaphore(lead_id) for lead_id in lead_ids],
            return_exceptions=True,
        )
        
        successful = sum(1 for r in results if isinstance(r, dict) and r.get("name"))
        failed = sum(1 for r in results if isinstance(r, Exception))
        
        logger.info(f"Batch enrichment complete: {successful} successful, {failed} failed")
        
        return {
            "total": len(lead_ids),
            "enriched": successful,
            "failed": failed,
        }
