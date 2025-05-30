# --- Stage 1: Build Stage ---
FROM python:3.13-alpine3 as builder

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache gcc musl-dev postgresql-dev

# Copy requirements files and install dependencies
COPY requirements.txt requirements-server.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-server.txt

# Copy application code
COPY . .

# --- Stage 2: Production Stage ---
FROM python:3.13-alpine3

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/. .

# Set environment variables
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

# Expose the application port
EXPOSE 8000/tcp

# Run database migrations and start the application using gunicorn
CMD ["/bin/sh", "-c", "flask db upgrade && gunicorn app:app -b 0.0.0.0:8000"]