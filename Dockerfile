# ==============================================================================
# STAGE 1: Base image with build tools & uv
# ==============================================================================
FROM python:3.13-slim-bookworm AS base

# Prevent Python from writing bytecode to disk & ensure immediate logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

# Install compilation tools needed only for building C-extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        libssl-dev \
        libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Force standalone copies rather than symlinks back to /root
ENV UV_LINK_MODE=copy \
    UV_PYTHON_PREFERENCE=only-system \
    VIRTUAL_ENV=/app/.venv


# ==============================================================================
# STAGE 2: Builder stage (Dependency Sync)
# ==============================================================================
FROM base AS builder
WORKDIR /app

ENV UV_COMPILE_BYTECODE=1

# 1. Create virtual environment using system Python explicitly
RUN uv venv --python /usr/local/bin/python $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 2. Copy dependency manifests first for layer caching
COPY pyproject.toml uv.lock ./

# 3. Install ONLY third-party dependencies (skips root project installation)
RUN uv sync --frozen --no-dev --no-install-project --python /usr/local/bin/python

# 4. Copy source files and install the root project if pyproject.toml defines it
COPY . /app
RUN . /app/.venv/bin/activate && \
    uv sync --frozen --no-dev --python /usr/local/bin/python

# Builder verification
RUN ls -la /app/.venv/bin/


# ==============================================================================
# STAGE 3: Runtime stage (Clean, Minimal Production Image)
# ==============================================================================
FROM python:3.13-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Install minimal runtime shared libraries if needed (e.g. ca-certificates)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home appuser && \
    chown -R appuser:appuser /app

# Copy virtual environment and source code with appuser ownership
COPY --chown=appuser:appuser --from=builder /app/.venv /app/.venv
COPY --chown=appuser:appuser assets/ assets/
COPY --chown=appuser:appuser classes/ classes/
COPY --chown=appuser:appuser main.py run.py README.md debug.log ./

USER appuser

# Runtime verification (using standard python, since uv is not in slim runtime)
RUN python -c "import importlib.metadata; print('\n'.join(f'{d.metadata[\"Name\"]}: {d.version}' for d in importlib.metadata.distributions()))"

ENTRYPOINT ["python", "run.py"]