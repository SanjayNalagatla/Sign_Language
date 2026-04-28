from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # API Configurations
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Sign Language to Text & Speech API"
    
    # Model Thresholds
    CONFIDENCE_THRESHOLD: float = 0.70
    SMOOTHING_WINDOW_SIZE: int = 10
    
    # Model Paths
    ASL_MODEL_PATH: str = "models/asl_static.h5"
    WLASL_MODEL_PATH: str = "models/wlasl_dynamic.h5"

    class Config:
        env_file = ".env"

settings = Settings()
