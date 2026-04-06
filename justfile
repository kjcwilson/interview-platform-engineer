set shell := ["bash", "-c"]

# List all available commands
default:
    @just --list

# --- Local Development ---

# Install project dependencies into the local environment
install:
    cd embeddings && uv sync

# Run the API locally on your host machine
run: install
    cd embeddings && uv run uvicorn main:app --reload

# --- Docker Environment ---

# Build the Docker container 
build:
    docker build -t embeddings-api:latest .

# Run the API service via Docker Compose
up:
    docker compose up --build -d
    @echo "Embeddings API is starting up..."
    @echo "Try out the interactive docs: http://localhost:8000/docs"

# Stop the API service running in Docker
down:
    docker compose down

# Follow the container logs
logs:
    docker compose logs -f

# --- Testing ---

# Check if the API is healthy
health:
    curl -s http://localhost:8000/health

# Submit a test sentence for embedding
test:
    curl -s -X POST http://localhost:8000/embed \
      -H "Content-Type: application/json" \
      -d '{"text": "FastAPI and Just make a great combination"}'
