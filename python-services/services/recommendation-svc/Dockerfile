FROM python:3.11-slim
WORKDIR /app
COPY app /app/app
RUN pip install --no-cache-dir fastapi==0.115.* uvicorn==0.30.* requests==2.*
EXPOSE 8090
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8090"]


