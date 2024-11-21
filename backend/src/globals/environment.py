# external
from pydantic_settings import BaseSettings

class Environment(BaseSettings):
    OPENAI_API_KEY: str