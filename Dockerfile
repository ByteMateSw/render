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
ENV PG_PORT=5432

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

# Verificar variables críticas
if [ -z "\$PG_HOST" ] || [ -z "\$PG_USER" ] || [ -z "\$PG_PASS" ]; then
    echo "❌ ERROR: Variables de entorno de PostgreSQL no configuradas"
    echo "   Necesitas configurar: PG_HOST, PG_USER, PG_PASS, PG_DB"
    exit 1
fi

echo "🌐 Variables de entorno configuradas:"
echo "   - PG_HOST: \$PG_HOST"
echo "   - PG_PORT: \$PG_PORT"
echo "   - PG_DB: \$PG_DB"
echo "   - PG_USER: \$PG_USER"
echo "   - PORT: \$PORT"
echo "   - RENDER_EXTERNAL_URL: \$RENDER_EXTERNAL_URL"

# Crear archivo de configuración dinámico
CONFIG_FILE="/tmp/render-server.properties"
echo "🔧 Generando configuración dinámica en \$CONFIG_FILE..."

cat > "\$CONFIG_FILE" <<CONFIGEOF
engine.name=render-server
group.id=server
external.id=server-001
sync.url=\${RENDER_EXTERNAL_URL}/sync/supabase-server

db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://\${PG_HOST}:\${PG_PORT}/\${PG_DB}?sslmode=require&ssl=true
db.user=\${PG_USER}
db.password=\${PG_PASS}

db.pool.initial.size=3
db.pool.max.size=20
db.pool.min.idle=2
db.pool.max.idle=8
db.pool.max.wait=30000
db.pool.test.on.borrow=true
db.pool.test.while.idle=true
db.pool.validation.query=select 1

auto.registration=false
start.route.job=true
start.outgoing.batches.job=true
start.incoming.batches.job=true
start.statistics.job=true
start.synctriggers.job=true
start.push.job=true
start.pull.job=true
start.heartbeat.job=true
start.purge.job=true

job.routing.period.time.ms=5000
job.outgoing.batches.period.time.ms=5000
job.incoming.batches.period.time.ms=5000
job.push.period.time.ms=10000
job.pull.period.time.ms=10000
job.heartbeat.period.time.ms=30000

web.enable=true
web.http.port=\${PORT}
web.context.path=/sync
web.base.url=\${RENDER_EXTERNAL_URL}

log.level=INFO
console.log.level=INFO
auto.config.database=true
auto.config.registration=true
CONFIGEOF

echo "✅ Configuración creada exitosamente"

# Mostrar resumen
echo "🔍 Resumen de configuración:"
echo "   - Base de datos: \$PG_HOST:\$PG_PORT/\$PG_DB"
echo "   - Usuario DB: \$PG_USER"
echo "   - Puerto web: \$PORT"
echo "   - URL sync: \$RENDER_EXTERNAL_URL/sync/supabase-server"

# Configurar entorno de SymmetricDS
export SYM_HOME="/app"
export JAVA_HOME="\$(dirname \$(dirname \$(readlink -f \$(which java))))"

# Crear directorio de logs
mkdir -p logs
touch logs/symmetric.log

# Iniciar SymmetricDS directamente
echo "🎯 Iniciando SymmetricDS..."
echo "⏰ Hora de inicio: \$(date)"

# Usar el script sym con el archivo de configuración
exec bin/sym --properties-file "\$CONFIG_FILE" --port "\$PORT"
EOF

# Hacer ejecutable el script de entrada
RUN chmod +x /app/docker-entrypoint.sh

# Comando por defecto
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# ===============================================================================
# NOTAS PARA RENDER.COM:
# ===============================================================================
# 
# 1. VARIABLES DE ENTORNO OBLIGATORIAS EN RENDER.COM:
#    - PG_HOST: Host de PostgreSQL (ej: db.xxx.supabase.co)
#    - PG_PORT: Puerto de PostgreSQL (default: 5432)
#    - PG_DB: Nombre de la base de datos
#    - PG_USER: Usuario de PostgreSQL
#    - PG_PASS: Password de PostgreSQL
#
# 2. VARIABLES OPCIONALES:
#    - JAVA_OPTS: Opciones de JVM (default: -Xmx1024m -Xms512m)
#    - PORT: Puerto web (auto-configurado por Render.com)
#    - RENDER_EXTERNAL_URL: URL externa (auto-configurada por Render.com)
#
# 3. CONFIGURACIÓN DEL SERVICIO EN RENDER.COM:
#    - Environment: Docker
#    - Build Command: [automático]
#    - Start Command: [automático - usa ENTRYPOINT]
#    - Health Check Path: /sync/supabase-server
#
# 4. DESPUÉS DEL DEPLOY:
#    - URL será: https://tu-app.onrender.com
#    - Endpoint sync: https://tu-app.onrender.com/sync/supabase-server
#    - Ejecutar scripts SQL en PostgreSQL en el orden correcto
#
# ===============================================================================
