# ===============================================================================
# Dockerfile para SymmetricDS en Render.com
# ===============================================================================
# DESCRIPCIÓN: Dockerfile optimizado para desplegar SymmetricDS como servicio web
#              en Render.com con PostgreSQL en la nube
# ARQUITECTURA: Java 17 + SymmetricDS 3.16.5 + configuración personalizada
# ===============================================================================

# Usar imagen base oficial de OpenJDK 17 (compatible con Render.com)
FROM openjdk:17-jdk-slim

# Metadatos del contenedor
LABEL maintainer="Sistema de Sincronización SymmetricDS"
LABEL version="3.16.5"
LABEL description="SymmetricDS Master Node para sincronización MySQL <-> PostgreSQL"

# Variables de entorno por defecto (se pueden sobrescribir en Render.com)
ENV JAVA_OPTS="-Xmx1024m -Xms512m -Djava.awt.headless=true"
ENV SYMMETRIC_HOME="/app"
ENV SYMMETRIC_ENGINE="config_sync/engines/render-server.properties"
ENV PORT=8080

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar TODOS los archivos de SymmetricDS
COPY . .

# Asegurar que los scripts tengan permisos de ejecución
RUN chmod +x bin/* && \
    chmod +x config_sync/scripts/*.js 2>/dev/null || true

# Crear directorios necesarios si no existen
RUN mkdir -p logs tmp engines security

# Configurar zona horaria (ajustar según región)
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Exponer el puerto para Render.com
EXPOSE $PORT

# Health check para que Render.com verifique que el servicio está funcionando
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:$PORT/sync/supabase-server || exit 1

# Script de entrada personalizado
COPY <<EOF /app/docker-entrypoint.sh
#!/bin/bash
set -e

echo "🚀 Iniciando SymmetricDS Master Node..."
echo "📅 Fecha: \$(date)"
echo "🔧 Java Version: \$(java -version 2>&1 | head -n1)"
echo "💾 Memoria disponible: \$(free -h | grep Mem | awk '{print \$2}')"
echo "🌐 Variables de entorno:"
echo "   - SYMMETRIC_HOME: \$SYMMETRIC_HOME"
echo "   - SYMMETRIC_ENGINE: \$SYMMETRIC_ENGINE"
echo "   - PORT: \$PORT"
echo "   - JAVA_OPTS: \$JAVA_OPTS"

# Verificar que existe el archivo de configuración
if [ ! -f "\$SYMMETRIC_ENGINE" ]; then
    echo "❌ ERROR: No se encontró el archivo de configuración: \$SYMMETRIC_ENGINE"
    echo "📁 Archivos disponibles en config_sync/engines/:"
    ls -la config_sync/engines/ 2>/dev/null || echo "   Directorio no encontrado"
    exit 1
fi

echo "✅ Archivo de configuración encontrado: \$SYMMETRIC_ENGINE"

# Verificar conectividad de base de datos (opcional)
echo "🔍 Verificando configuración de base de datos..."
grep -E "^db\.(url|user)" "\$SYMMETRIC_ENGINE" | head -2 || echo "⚠️  No se pudieron leer configuraciones de DB"

# Mostrar configuración de sync.url
echo "🌐 URL de sincronización configurada:"
grep "^sync.url" "\$SYMMETRIC_ENGINE" || echo "⚠️  sync.url no configurada"

# Crear logs iniciales
touch logs/symmetric.log
echo "📝 Log iniciado en \$(date)" >> logs/symmetric.log

# Iniciar SymmetricDS en modo foreground para Render.com
echo "🎯 Ejecutando comando: bin/sym_service -engine \$SYMMETRIC_ENGINE start"
echo "⏰ Iniciando en \$(date)..."

# Ejecutar SymmetricDS
exec bin/sym_service -engine "\$SYMMETRIC_ENGINE" start
EOF

# Hacer ejecutable el script de entrada
RUN chmod +x /app/docker-entrypoint.sh

# Comando por defecto
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# ===============================================================================
# NOTAS PARA RENDER.COM:
# ===============================================================================
# 
# 1. VARIABLES DE ENTORNO A CONFIGURAR EN RENDER.COM:
#    - PG_HOST: Host de PostgreSQL
#    - PG_PORT: Puerto de PostgreSQL (default: 5432)
#    - PG_DB: Nombre de la base de datos
#    - PG_USER: Usuario de PostgreSQL
#    - PG_PASS: Password de PostgreSQL
#    - JAVA_OPTS: Opciones de JVM (default: -Xmx1024m -Xms512m)
#
# 2. CONFIGURACIÓN DEL SERVICIO EN RENDER.COM:
#    - Build Command: docker build -t symmetricds .
#    - Start Command: [se usa ENTRYPOINT del Dockerfile]
#    - Port: 8080
#    - Health Check Path: /sync/supabase-server
#
# 3. ANTES DE HACER BUILD:
#    Asegúrate de personalizar config_sync/engines/supabase-server.properties
#    con las variables de entorno correctas
#
# ===============================================================================
