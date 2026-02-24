# Embeddings API

A FastAPI service that converts text into vector embeddings using [`sentence-transformers`](https://www.sbert.net/).


## Requirements

- [uv](https://docs.astral.sh/uv/) — Python package manager
- Python 3.14 (automatically managed by uv)

## Running Locally

### 1. Install dependencies

```bash
uv sync
```

### 2. Start the server

```bash
uv run uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`.

> On first startup the model (`all-MiniLM-L6-v2`, ~90 MB) is downloaded from HuggingFace and cached locally. Subsequent starts are instant.

## Interactive Docs

FastAPI ships with built-in docs:

| UI         | URL                         |
| ---------- | --------------------------- |
| Swagger UI | http://localhost:8000/docs  |
| ReDoc      | http://localhost:8000/redoc |

## Endpoints

### `GET /health`

Returns service status.

```json
{"status": "ok"}
```

---

### `POST /embed`

Convert one or more strings into vectors.

**Request body**

```json
{
  "text": "Hello, world!"
}
```

or a batch:

```json
{
  "text": ["Hello, world!", "FastAPI is great"]
}
```

**Response**

```json
{
  "embeddings": [[0.021, -0.045, ...]],
  "model": "all-MiniLM-L6-v2",
  "dimensions": 384
}
```

## Example curl

```bash
curl -X POST http://localhost:8000/embed \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, world!"}'
```
