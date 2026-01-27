# 1. Lightweight Python base image
FROM python:3.10-slim

# 2. Set working directory inside container
WORKDIR /app

# 3. Copy requirements first (Docker cache optimization)
COPY requirements.txt .

# 4. Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy project files
COPY . .

# 6. Streamlit runs on port 8501 by default
EXPOSE 8501

# 7. Disable Streamlit telemetry & CORS issues
ENV STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
ENV STREAMLIT_SERVER_ENABLE_CORS=false
ENV STREAMLIT_SERVER_ENABLE_XSRF_PROTECTION=false

# 8. Start the app (EXACTLY how you already run it)
CMD ["streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.headless=true"]

