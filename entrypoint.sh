#!/usr/bin/env bash
set -e

# Ensure environment variables are available
echo "Starting entrypoint: running migrations and collecting static files"

# Wait for DB if necessary (user can extend this script to support Cloud SQL Proxy)
# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Launch gunicorn
exec gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8080} --workers 2
