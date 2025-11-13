# Dockerfile

# 1. IMAGEN BASE
FROM python:3.13-slim

# 2. VARIABLES DE ENTORNO BÁSICAS
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE smartsales.settings

# 3. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA (WEASYPRINT FIX)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libgobject-2.0-0 \
        libgirepository-1.0-1 \
        libcairo2 \
        libxml2 \
        libjpeg-dev \
        libfontconfig1 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# 4. CONFIGURACIÓN DE LA APLICACIÓN
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
COPY . /app/

# 5. COMANDO DE INICIO (CMD)
# Ejecuta migración, colecta estáticos, y finalmente inicia el servidor.
CMD python manage.py reset_all_data && \
    python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput && \
    python manage.py seed_users_data && \
    python manage.py seed_products_data && \
    python manage.py seed_ml && \
    python train_models.py && \
    gunicorn smartsales.wsgi -b 0.0.0.0:$PORT