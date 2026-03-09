"""Prioritization Agent - Scores and ranks leads"""
from typing import List, Dict, Any
from loguru import logger


class PrioritizationAgent:
    """Agent that scores and prioritizes leads"""
    
    # Scoring weights (matching B2BCore)
    WEIGHTS = {
        "project_value": 0.30,
        "completion_rate": 0.25,
        "contact_quality": 0.20,
        "timing_urgency": 0.15,
        "similar_projects": 0.10,
    }
    
    def calculate_score(
        self,
        project_value: float,
        completion_rate: float,
        contact_quality: float,
        timing_urgency: float,
        similar_projects: float,
    ) -> float:
        """Calculate weighted lead score (0-1)"""
        score = (
            self.WEIGHTS["project_value"] * project_value +
            self.WEIGHTS["completion_rate"] * completion_rate +
            self.WEIGHTS["contact_quality"] * contact_quality +
            self.WEIGHTS["timing_urgency"] * timing_urgency +
            self.WEIGHTS["similar_projects"] * similar_projects
        )
        return min(max(score, 0.0), 1.0)
    
    def get_tier(self, score: float) -> str:
        """Determine lead tier from score"""
        if score >= 0.70:
            return "hot"
        elif score >= 0.50:
            return "warm"
        elif score >= 0.30:
            return "cool"
        else:
            return "cold"
    
    async def score_lead(self, lead: Dict[str, Any]) -> Dict[str, Any]:
        """
        Score a lead based on available data.
        
        Args:
            lead: Lead dictionary from database
        
        Returns:
            Dict with score, tier, and component breakdown
        """
        # Project value (normalized on log scale, max $10M)
        project_value = lead.get("project_value") or 0
        value_score = min(1.0, (project_value / 10_000_000) ** 0.5) if project_value > 0 else 0
        
        # Completion rate
        completed = lead.get("contractor_projects_completed") or 0
        total = max(completed, 1)  # Avoid div/0
        completion_score = completed / total if completed else 0.5
        
        # Contact quality (1.0 if email+phone, 0.7 if email only, 0.3 if phone only, 0 if none)
        has_email = bool(lead.get("decision_maker_email"))
        has_phone = bool(lead.get("decision_maker_phone"))
        if has_email and has_phone:
            contact_score = 1.0
        elif has_email:
            contact_score = 0.7
        elif has_phone:
            contact_score = 0.3
        else:
            contact_score = 0.0
        
        # Timing urgency (approved/in_progress = 1.0, filed = 0.5, else 0.2)
        status = lead.get("status", "pending")
        if status in ("hot", "qualified"):
            timing_score = 1.0
        elif status == "enriched":
            timing_score = 0.7
        else:
            timing_score = 0.5
        
        # Similar projects (placeholder - would check contractor history)
        similar_score = 0.5
        
        # Calculate total score
        total_score = self.calculate_score(
            value_score,
            completion_score,
            contact_score,
            timing_score,
            similar_score,
        )
        
        return {
            "score": total_score,
            "tier": self.get_tier(total_score),
            "components": {
                "project_value": value_score,
                "completion_rate": completion_score,
                "contact_quality": contact_score,
                "timing_urgency": timing_score,
                "similar_projects": similar_score,
            },
        }
    
    async def prioritize_leads(
        self,
        leads: List[Dict[str, Any]],
    ) -> List[Dict[str, Any]]:
        """
        Score and sort leads by priority.
        
        Args:
            leads: List of lead dictionaries
        
        Returns:
            List of leads with scores, sorted by score descending
        """
        scored_leads = []
        
        for lead in leads:
            score_data = await self.score_lead(lead)
            lead_with_score = {
                **lead,
                "score": score_data["score"],
                "tier": score_data["tier"],
                "score_components": score_data["components"],
            }
            scored_leads.append(lead_with_score)
        
        # Sort by score descending
        scored_leads.sort(key=lambda x: x["score"], reverse=True)
        
        logger.info(f"Prioritized {len(scored_leads)} leads")
        return scored_leads
