FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
COPY requirements.lock.txt .
RUN pip install -r requirements.txt

# Copy and build frontend
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install
RUN npm run build
WORKDIR /app

# Copy backend and model assets
COPY app/ ./app/
COPY data/ ./data/
COPY yolov8n.pt .

# Copy static frontend (now built)
COPY frontend/dist/ ./frontend/dist/

# Optionally include example env and scripts
COPY scripts/ ./scripts/
COPY .env.example .

# Expose port
EXPOSE 8000

# Launch API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
