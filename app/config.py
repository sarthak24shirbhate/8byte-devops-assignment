import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    APP_NAME: str = os.getenv("APP_NAME", "8byte-devops-service")
    APP_VERSION: str = os.getenv("APP_VERSION", "1.0.0")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "dev")
    PORT: int = int(os.getenv("PORT", "8000"))
    HOST: str = os.getenv("HOST", "0.0.0.0")
    
    # Database Settings
    DB_HOST: str = os.getenv("DB_HOST", "")
    DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
    DB_NAME: str = os.getenv("DB_NAME", "appdb")
    DB_USER: str = os.getenv("DB_USER", "appadmin")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    
    @property
    def database_url(self) -> str:
        if self.DB_HOST and self.DB_PASSWORD:
            return f"postgresql://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        return "sqlite:///./local_test.db"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
