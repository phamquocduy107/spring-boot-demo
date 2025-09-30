FROM python:3.11-slim

WORKDIR /app

# Copy application code
COPY app /app/app

# Install dependencies
RUN pip install --no-cache-dir \
    fastapi==0.115.* \
    uvicorn==0.30.* \
    requests==2.* \
    pydantic==2.*

# Expose port
EXPOSE 8090

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8090"]
