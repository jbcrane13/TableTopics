"""Repository for lead CRUD operations"""
from typing import List, Optional
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from leadforge.db.models import LeadModel
from leadforge.models.lead import Lead, LeadStatus


class LeadRepository:
    """Async repository for lead operations"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def create(self, lead: Lead) -> LeadModel:
        """Create a new lead"""
        db_lead = LeadModel(
            id=lead.id,
            permit_id=lead.permit_id,
            city=lead.city,
            state=lead.state,
            zip_code=lead.zip_code,
            project_type=lead.project_type,
            project_value=lead.project_value,
            permit_date=lead.permit_date,
            contractor_name=lead.contractor_name,
            contractor_id=lead.contractor_id,
            score=lead.score,
            status=lead.status,
            decision_maker_name=lead.decision_maker_name,
            decision_maker_title=lead.decision_maker_title,
            decision_maker_email=lead.decision_maker_email,
            decision_maker_phone=lead.decision_maker_phone,
            contractor_projects_completed=lead.contractor_projects_completed,
            contractor_rating=lead.contractor_rating,
        )
        self.session.add(db_lead)
        await self.session.commit()
        await self.session.refresh(db_lead)
        return db_lead
    
    async def get(self, lead_id: str) -> Optional[LeadModel]:
        """Get a lead by ID"""
        result = await self.session.execute(
            select(LeadModel).where(LeadModel.id == lead_id)
        )
        return result.scalar_one_or_none()
    
    async def get_by_permit(self, permit_id: str) -> Optional[LeadModel]:
        """Get a lead by permit ID"""
        result = await self.session.execute(
            select(LeadModel).where(LeadModel.permit_id == permit_id)
        )
        return result.scalar_one_or_none()
    
    async def list(
        self,
        city: Optional[str] = None,
        project_type: Optional[str] = None,
        status: Optional[LeadStatus] = None,
        min_score: Optional[float] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[LeadModel]:
        """List leads with optional filtering"""
        query = select(LeadModel)
        
        conditions = []
        if city:
            conditions.append(LeadModel.city.ilike(f"%{city}%"))
        if project_type:
            conditions.append(LeadModel.project_type == project_type)
        if status:
            conditions.append(LeadModel.status == status)
        if min_score is not None:
            conditions.append(LeadModel.score >= min_score)
        
        if conditions:
            query = query.where(and_(*conditions))
        
        query = query.order_by(LeadModel.score.desc())
        query = query.offset(offset).limit(limit)
        
        result = await self.session.execute(query)
        return list(result.scalars().all())
    
    async def count(
        self,
        city: Optional[str] = None,
        project_type: Optional[str] = None,
        status: Optional[LeadStatus] = None,
        min_score: Optional[float] = None,
    ) -> int:
        """Count leads with optional filtering"""
        from sqlalchemy import func
        
        query = select(func.count(LeadModel.id))
        
        conditions = []
        if city:
            conditions.append(LeadModel.city.ilike(f"%{city}%"))
        if project_type:
            conditions.append(LeadModel.project_type == project_type)
        if status:
            conditions.append(LeadModel.status == status)
        if min_score is not None:
            conditions.append(LeadModel.score >= min_score)
        
        if conditions:
            query = query.where(and_(*conditions))
        
        result = await self.session.execute(query)
        return result.scalar_one()
    
    async def update(self, lead_id: str, **kwargs) -> Optional[LeadModel]:
        """Update a lead"""
        db_lead = await self.get(lead_id)
        if not db_lead:
            return None
        
        for key, value in kwargs.items():
            if hasattr(db_lead, key):
                setattr(db_lead, key, value)
        
        await self.session.commit()
        await self.session.refresh(db_lead)
        return db_lead
    
    async def delete(self, lead_id: str) -> bool:
        """Delete a lead"""
        db_lead = await self.get(lead_id)
        if not db_lead:
            return False
        
        await self.session.delete(db_lead)
        await self.session.commit()
        return True
    
    async def upsert(self, lead: Lead) -> LeadModel:
        """Create or update a lead (by permit_id)"""
        existing = await self.get_by_permit(lead.permit_id)
        
        if existing:
            # Update existing
            return await self.update(
                existing.id,
                city=lead.city,
                state=lead.state,
                zip_code=lead.zip_code,
                project_type=lead.project_type,
                project_value=lead.project_value,
                permit_date=lead.permit_date,
                contractor_name=lead.contractor_name,
                score=lead.score,
                status=lead.status,
            )
        else:
            # Create new
            return await self.create(lead)
