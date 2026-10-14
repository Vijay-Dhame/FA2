# ---- Backend Dockerfile ----
# DevOps Environment Manager — FastAPI backend
FROM python:3.12-slim

LABEL maintainer="Vijay Dhame"
LABEL description="DevOps Environment Manager Backend"

# Prevent Python from buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
