FROM python:3.12-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.txt

# Copy project
COPY . /app

# Make entrypoint executable and create a non-root user
RUN chmod +x /app/entrypoint.sh \
    && adduser --disabled-password --gecos '' writeruser || true \
    && chown -R writeruser /app

USER writeruser

EXPOSE 8080

ENV DJANGO_SETTINGS_MODULE=config.settings

ENTRYPOINT ["/app/entrypoint.sh"]
