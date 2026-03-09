"""Database connection and session management"""
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy import create_engine
from leadforge.core.config import get_settings

settings = get_settings()

# Use SQLite for development, Postgres for production
DATABASE_URL = settings.database_url
if DATABASE_URL.startswith("postgresql"):
    # Convert to async
    DATABASE_URL = DATABASE_URL.replace("postgresql+asyncpg://", "sqlite+aiosqlite:///./leadforge.db")
    if "localhost" in DATABASE_URL:
        # Fallback to SQLite for local dev
        DATABASE_URL = "sqlite+aiosqlite:///./leadforge.db"

# Async engine
engine = create_async_engine(
    DATABASE_URL,
    echo=settings.debug,
    future=True
)

# Session factory
async_session = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Base class for models
Base = declarative_base()


async def get_db() -> AsyncSession:
    """Dependency to get database session"""
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db():
    """Initialize database tables"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def close_db():
    """Close database connections"""
    await engine.dispose()
