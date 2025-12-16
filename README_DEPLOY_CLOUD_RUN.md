# Deploy to Google Cloud Run

This document shows the minimal set of files and commands to containerize and deploy this Django app to Google Cloud Run.

## Prerequisites

- `gcloud` CLI installed and authenticated: `gcloud auth login`
- Billing enabled on your GCP project
- Cloud Build API enabled: `gcloud services enable cloudbuild.googleapis.com`
- Cloud Run API enabled: `gcloud services enable run.googleapis.com`

## Files Provided

- `Dockerfile` — container build instructions (Python 3.11, Gunicorn, non-root user)
- `.dockerignore` — excludes local files and artifacts from build context
- `entrypoint.sh` — runs migrations, collectstatic, and launches Gunicorn
- `requirements.txt` — Python dependencies (Django, Gunicorn, Whitenoise, Google Cloud Secret Manager)
- `cloudbuild.yaml` — Cloud Build pipeline to build image and deploy to Cloud Run
- `config/settings.py` — updated for Cloud Run with env var configuration

## Environment Variables Required

The app reads the following from environment variables (set via `--set-env-vars` or Secret Manager):

| Variable | Default | Purpose |
|----------|---------|---------|
| `SECRET_KEY` | `dev-key-change-in-production` | Django secret key (MUST set to a secure random value in production) |
| `DEBUG` | `False` | Set to `True` only for development/staging |
| `ALLOWED_HOSTS` | `localhost,127.0.0.1` | Comma-separated list of allowed hostnames (Cloud Run URL) |
| `DJANGO_SETTINGS_MODULE` | — | Set to `config.settings` (configured in cloudbuild.yaml) |
| `STATIC_ROOT` | `BASE_DIR/staticfiles` | Where to collect static files |

## Quick Deploy (Cloud Build)

### Step 1: Generate a secure SECRET_KEY

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the output for use in the next step.

### Step 2: Set your project ID

```bash
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

### Step 3: Submit Cloud Build

```bash
gcloud builds submit --config cloudbuild.yaml --substitutions=_REGION=us-central1
```

This will:
1. Build the Docker image
2. Push to Google Container Registry (`gcr.io/YOUR_PROJECT_ID/writer:SHORT_SHA`)
3. Deploy to Cloud Run with the image

### Step 4: Set environment variables after deployment

After the Cloud Run service is deployed, update its environment variables:

```bash
gcloud run services update writer \
  --region us-central1 \
  --update-env-vars "DEBUG=False,SECRET_KEY=<generated-key-from-step-1>,ALLOWED_HOSTS=<service-url>"
```

Where `<service-url>` is your Cloud Run service URL (e.g., `writer-abc123.run.app`).

## Local Testing (Docker)

If Docker is available locally:

```bash
docker build -t writer:local .
docker run \
  -e DEBUG=False \
  -e SECRET_KEY="your-secret-key" \
  -e ALLOWED_HOSTS="localhost" \
  -p 8080:8080 \
  writer:local
```

Then visit `http://localhost:8080`.

## Important Notes

### Data Persistence
- This project uses **SQLite3**, which stores data in the container's filesystem
- Cloud Run's filesystem is **ephemeral** — data is lost when the instance stops or scales down
- For production apps requiring persistent data, migrate to **Cloud SQL** (Postgres) or another managed database

### Security
- **Never commit `SECRET_KEY` to the repository** — generate a new one per environment
- Use **Google Cloud Secret Manager** for sensitive variables (recommended for production)
- `DEBUG=False` in production to prevent sensitive information exposure
- `ALLOWED_HOSTS` must be set to specific Cloud Run domain(s) to prevent host header attacks

Local build and run (Docker):

```bash
docker build -t writer:local .
docker run -e PORT=8080 -p 8080:8080 writer:local
```

Next steps (optional)
- Integrate Cloud SQL: add `cloudsql` connection and configure `cloudbuild.yaml` to grant the Cloud Run service account access.
- Add a Health check endpoint and increase `gunicorn` worker count for production traffic.
