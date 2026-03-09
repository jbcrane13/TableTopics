"""LeadForge FastAPI Application"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from leadforge.core.config import get_settings
from leadforge.db.database import init_db, close_db
from leadforge.api import leads, agents

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan - initialize and cleanup"""
    # Startup
    await init_db()
    yield
    # Shutdown
    await close_db()


app = FastAPI(
    title="LeadForge",
    description="AI Lead Generation Platform for Table Topics",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "LeadForge API", "version": "0.1.0"}


@app.get("/health")
async def health():
    return {"status": "healthy"}


# Include routers
app.include_router(leads.router, tags=["leads"])
app.include_router(agents.router, tags=["agents"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
