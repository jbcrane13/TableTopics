"""PermitScout Agent - Finds building permits via Shovels API"""
import json
import subprocess
import uuid
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from loguru import logger

from leadforge.models.lead import Lead, LeadStatus
from leadforge.db.repository import LeadRepository


class PermitScoutAgent:
    """Agent that searches for building permits using Shovels API"""
    
    # Target keywords for Table Topics (hotel/restaurant industry)
    TARGET_KEYWORDS = [
        "hotel", "restaurant", "hospitality", "dining", "bar",
        "motel", "resort", "cafe", "brewery", "tavern",
        "kitchen", "dining room", "food service"
    ]
    
    # Permit types that indicate hospitality projects
    TARGET_PERMIT_TYPES = [
        "new_construction", "remodel", "renovation", "addition",
        "tenant_improvement", "alteration"
    ]
    
    def __init__(self, shovels_cli: str = "/Users/blake/.shovels/shovels"):
        self.shovels_cli = shovels_cli
    
    async def search_permits(
        self,
        city: str,
        state: str,
        min_value: int = 50000,
        days_ago: int = 90,
        limit: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Search for building permits in a city.
        
        Args:
            city: City name (e.g., "Austin")
            state: State code (e.g., "TX")
            min_value: Minimum project value in dollars
            days_ago: How many days back to search
            limit: Maximum number of results
        
        Returns:
            List of permit dictionaries from Shovels API
        """
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_ago)
        
        # First, resolve city to geo_id
        geo_id = await self._resolve_geo_id(city, state)
        if not geo_id:
            logger.warning(f"Could not resolve geo_id for {city}, {state}")
            return []
        
        cmd = [
            self.shovels_cli,
            "permits", "search",
            "--geo-id", geo_id,
            "--permit-from", start_date.strftime("%Y-%m-%d"),
            "--permit-to", end_date.strftime("%Y-%m-%d"),
            "--min-job-value", str(min_value),
            "--limit", str(limit),
        ]
        
        # Add target permit types
        for pt in self.TARGET_PERMIT_TYPES[:3]:  # Limit to avoid too many params
            cmd.extend(["--tags", pt])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                timeout=30
            )
            data = json.loads(result.stdout)
            permits = data.get("data", [])
            
            # Filter for hospitality targets
            filtered = self._filter_for_hospitality(permits)
            logger.info(f"Found {len(filtered)} hospitality permits from {len(permits)} total")
            
            return filtered
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Shovels CLI error: {e.stderr}")
            return []
        except subprocess.TimeoutExpired:
            logger.error("Shovels CLI timeout")
            return []
        except json.JSONDecodeError as e:
            logger.error(f"JSON parse error: {e}")
            return []
    
    async def _resolve_geo_id(self, city: str, state: str) -> Optional[str]:
        """Resolve city/state to Shovels geo_id"""
        cmd = [
            self.shovels_cli,
            "cities", "search",
            "-q", f"{city}, {state}"
        ]
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                timeout=10
            )
            data = json.loads(result.stdout)
            cities = data.get("data", [])
            
            if cities:
                # Find exact match for state
                for c in cities:
                    if c.get("state", "").upper() == state.upper():
                        return c.get("geo_id")
                # Fall back to first result
                return cities[0].get("geo_id")
            
            return None
            
        except Exception as e:
            logger.error(f"Error resolving geo_id: {e}")
            return None
    
    def _filter_for_hospitality(self, permits: List[Dict]) -> List[Dict]:
        """Filter permits for hospitality-related projects"""
        filtered = []
        
        for permit in permits:
            desc = str(permit.get("description", "")).lower()
            prop_type = str(permit.get("property_type_detail", "")).lower()
            work_type = str(permit.get("work_type", "")).lower()
            
            # Check if any target keyword appears in relevant fields
            combined_text = f"{desc} {prop_type} {work_type}"
            
            if any(kw in combined_text for kw in self.TARGET_KEYWORDS):
                filtered.append(permit)
        
        return filtered
    
    def permit_to_lead(self, permit: Dict[str, Any]) -> Lead:
        """Convert a Shovels permit to a Lead"""
        permit_id = permit.get("id", str(uuid.uuid4()))
        
        # Extract contractor info
        contractor = permit.get("contractor", {}) or {}
        contractor_name = contractor.get("name") or permit.get("contractor_name", "Unknown")
        contractor_id = contractor.get("id") or permit.get("contractor_id")
        
        # Extract location
        address = permit.get("address", {}) or {}
        city = address.get("city", "Unknown")
        state = address.get("state", "XX")
        zip_code = address.get("zip_code") or address.get("zip")
        
        # Extract project details
        project_type = permit.get("permit_type", "other")
        project_value = permit.get("job_value") or permit.get("estimated_value")
        permit_date_str = permit.get("permit_date") or permit.get("filed_date")
        
        # Parse permit date
        if permit_date_str:
            try:
                permit_date = datetime.fromisoformat(permit_date_str.replace("Z", "+00:00"))
            except:
                permit_date = datetime.now()
        else:
            permit_date = datetime.now()
        
        return Lead(
            id=f"shovels-{permit_id}",
            permit_id=permit_id,
            city=city,
            state=state,
            zip_code=zip_code,
            project_type=project_type,
            project_value=int(project_value) if project_value else None,
            permit_date=permit_date,
            contractor_name=contractor_name,
            contractor_id=contractor_id,
            score=0.0,  # Will be calculated by scoring agent
            status=LeadStatus.PENDING,
        )
    
    async def get_contractor_details(self, contractor_id: str) -> Dict[str, Any]:
        """Get detailed contractor information from Shovels"""
        cmd = [
            self.shovels_cli,
            "contractors", "get", contractor_id,
        ]
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                timeout=15
            )
            data = json.loads(result.stdout)
            return data.get("data", {})
        except Exception as e:
            logger.error(f"Error fetching contractor: {e}")
            return {}
    
    async def run(
        self,
        repo: LeadRepository,
        city: str,
        state: str,
        min_value: int = 50000,
        days_ago: int = 90,
    ) -> List[Lead]:
        """
        Main entry point: Search permits and save to database.
        
        Args:
            repo: LeadRepository for database operations
            city: City to search
            state: State code
            min_value: Minimum project value
            days_ago: Days to look back
        
        Returns:
            List of newly created leads
        """
        logger.info(f"PermitScout: Searching {city}, {state}")
        
        # Search for permits
        permits = await self.search_permits(
            city=city,
            state=state,
            min_value=min_value,
            days_ago=days_ago,
        )
        
        # Convert to leads and save
        new_leads = []
        for permit in permits:
            lead = self.permit_to_lead(permit)
            
            # Check if already exists
            existing = await repo.get_by_permit(lead.permit_id)
            if existing:
                logger.debug(f"Lead already exists: {lead.permit_id}")
                continue
            
            # Save to database
            db_lead = await repo.create(lead)
            new_leads.append(Lead.model_validate(db_lead))
            logger.info(f"Created lead: {db_lead.id} - {db_lead.contractor_name}")
        
        logger.info(f"PermitScout: Created {len(new_leads)} new leads")
        return new_leads
