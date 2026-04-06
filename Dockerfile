FROM python:3.14-slim AS builder

# Copy uv from the official astral-sh image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Configure UV defaults for faster, reproducible builds
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Optimize size: Pull CPU-only versions of massive ML packages, 
# ensuring the image is practical for local macOS deployment
ENV UV_EXTRA_INDEX_URL=https://download.pytorch.org/whl/cpu

WORKDIR /app

# Install dependencies in a separate layer to maximize cache hits
COPY embeddings/pyproject.toml embeddings/uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Copy the rest of the application
COPY embeddings/ ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Bake model weights into the image so they are not re-downloaded at runtime
ENV HF_HOME=/app/models
RUN --mount=type=cache,target=/root/.cache/uv \
    uv run python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

# -------------------------
# Stage 2: Production Image
# -------------------------
FROM python:3.14-slim

# Copy the pre-built environment and baked models
COPY --from=builder /app /app

# Ensure curl is installed for the healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set PATH to use the virtualenv as the default python
ENV PATH="/app/.venv/bin:$PATH"
ENV HF_HOME=/app/models

EXPOSE 8000

# Start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
