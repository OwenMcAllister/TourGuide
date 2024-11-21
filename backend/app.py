# builtin
from contextlib import asynccontextmanager
import os

# external
from fastapi import FastAPI
from dotenv import load_dotenv

# internal
from src.routes import setup_routes
from src.globals.environment import Environment


# Load .env file
load_dotenv()


def setup_environment(app: FastAPI):
    environment = Environment()
    app.state.environment = environment


def setup_modules(app: FastAPI):

    setup_routes(app)


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Starting up")
    setup_environment(app)
    setup_modules(app)
    yield
    print("Shutting down")


app = FastAPI(lifespan=lifespan)


@app.get("/")
async def root():
    return {"message": "Sanity Check"}