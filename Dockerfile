FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for caching
COPY requirements-hf.txt .

# Install Python dependencies (CPU-only PyTorch to save space)
RUN pip install --no-cache-dir -r requirements-hf.txt

# Copy application code
COPY app/ ./app/
COPY trained_models/ ./trained_models/

# HF Spaces requires port 7860
EXPOSE 7860

# Start the server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
