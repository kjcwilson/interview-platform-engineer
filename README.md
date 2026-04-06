# Embeddings API

A small REST API that accepts text and returns vector embeddings using `sentence-transformers`. It's pre-configured and containerized so you can easily run it locally.

## Prerequisites

Ensure you have the following installed before proceeding:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)**: Required to run the application in a container. Must be running.
- **[Just](https://just.systems/man/en/)** (Optional but recommended): Command runner to simplify terminal tasks. macOS users can install it via Homebrew: `brew install just`.
- **[uv](https://docs.astral.sh/uv/getting-started/installation/)** (Optional): A fast Python package installer and resolver. Required only if you plan to run the application natively outside of Docker. macOS users can install it via Homebrew: `brew install uv`.

## Quickstart (Using Docker and `just`)

The fastest way to get started is by running the pre-configured Docker container via `just`. The container bakes the ML model weights directly into the image so they are not re-downloaded at runtime. The initial build may take a minute, but subsequent runs will be near-instant.

1. **Start the API in the background:**
   ```bash
   just up
   ```

2. **Check if the API is healthy:**
   ```bash
   just health
   ```

3. **Submit a test request:**
   ```bash
   just test
   ```

4. **View interactive API documentation:**
   Open [http://localhost:8000/docs](http://localhost:8000/docs) in your browser.

5. **Stop the API and clean up:**
   ```bash
   just down
   ```

## Running Without `just`

If you prefer not to install `just`, you can run the equivalent underlying commands directly using Docker Compose:

- **Start the API:**
  ```bash
  docker compose up --build -d
  ```

- **Follow application logs:**
  ```bash
  docker compose logs -f
  ```

- **Stop the API:**
  ```bash
  docker compose down
  ```

- **Test the embedding endpoint manually:**
  ```bash
  curl -X POST http://localhost:8000/embed \
    -H "Content-Type: application/json" \
    -d '{"text": "FastAPI and Docker make a great combination"}'
  ```

## Running Natively Without Docker

If you want to run the project directly on your host machine to aid with rapid development, make sure you have `uv` installed, then run:

```bash
just run
```
*(Under the hood, this evaluates to: `cd embeddings && uv sync` followed by `uv run uvicorn main:app --reload`)*

## Note on Architecture (CPU vs. GPU)

By default, the `Dockerfile` is configured to install the **CPU-only** version of PyTorch. This decision drastically reduces the size of the final container image and makes the setup practical for local development on everyday laptops without discrete GPUs.

**Production Workloads:**
If you plan to deploy this application to a production environment that has access to GPU acceleration, you should update the `Dockerfile` by removing or altering the following line:

```dockerfile
ENV UV_EXTRA_INDEX_URL=https://download.pytorch.org/whl/cpu
```

Removing this environment variable allows the package manager to download the standard, full-sized PyTorch distributions that include CUDA support.
