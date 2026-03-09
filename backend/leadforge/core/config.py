"""Application configuration"""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""
    app_name: str = "LeadForge"
    debug: bool = False
    
    # Shovels API
    shovels_api_key: str = ""
    shovels_base_url: str = "https://api.shovels.ai/v2"
    
    # OpenAI/Anthropic
    openai_api_key: str = ""
    anthropic_api_key: str = ""
    
    # Database
    database_url: str = "postgresql+asyncpg://localhost/leadforge"
    
    # Redis (for Celery)
    redis_url: str = "redis://localhost:6379/0"
    
    class Config:
        env_file = ".env"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
