# Dockerfile

# 1. IMAGEN BASE
# Usa una imagen base de Python (3.13) en modo slim para reducir el tamaño
FROM python:3.13-slim

# 2. VARIABLES DE ENTORNO BÁSICAS
# Configuraciones estándar para contenedores Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE smartsales.settings

# 3. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA (WEASYPRINT FIX)
# Esto resuelve el error "OSError: cannot load library 'libgobject-2.0-0'"

# Actualiza la lista de paquetes e instala las librerías necesarias para WeasyPrint (GObject, Pango, Cairo)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Dependencias de WeasyPrint / GObject
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libgobject-2.0-0 \
        libgirepository-1.0-1 \
        libcairo2 \
        libxml2 \
        libjpeg-dev \
        libfontconfig1 \
        # Limpieza
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# 4. CONFIGURACIÓN DE LA APLICACIÓN
# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de dependencia
COPY requirements.txt /app/

# Instala las dependencias de Python
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copia el resto del código de la aplicación
COPY . /app/

# 5. COMANDO DE INICIO (CMD)
# Este comando se ejecuta al iniciar el contenedor.
# Ejecuta el reseteo, migraciones, seeders y finalmente inicia el servidor Gunicorn.
# (Asegúrate que 'smartsales' sea el nombre de tu carpeta de configuración de Django)
# Dockerfile (Sección CMD) - SOLO MIGRAR E INICIAR

CMD python manage.py migrate --noinput && \
    gunicorn smartsales.wsgi -b 0.0.0.0:$PORT