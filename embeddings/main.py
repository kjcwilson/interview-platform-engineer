from contextlib import asynccontextmanager
from typing import Union

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

model: Union[SentenceTransformer, None] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    model = SentenceTransformer("all-MiniLM-L6-v2")
    yield
    model = None


app = FastAPI(
    title="Embeddings API",
    description="Convert text into vector embeddings using sentence-transformers.",
    version="0.1.0",
    lifespan=lifespan,
)


class EmbedRequest(BaseModel):
    text: str | list[str]


class EmbedResponse(BaseModel):
    embeddings: list[list[float]]
    model: str
    dimensions: int


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/embed", response_model=EmbedResponse)
def embed(request: EmbedRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    texts = request.text if isinstance(request.text, list) else [request.text]
    vectors = model.encode(texts, convert_to_numpy=True).tolist()

    return EmbedResponse(
        embeddings=vectors,
        model="all-MiniLM-L6-v2",
        dimensions=len(vectors[0]),
    )
