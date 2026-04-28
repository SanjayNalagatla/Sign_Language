from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router

app = FastAPI(
    title="Sign Language to Text & Speech API",
    description="Backend service for recognizing sign language gestures and sequence processing.",
    version="1.0.0"
)

# Allow cross-origin requests for Flutter Mobile/Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register endpoints
app.include_router(router, prefix="/api/v1")

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Sign Language API is running."}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
