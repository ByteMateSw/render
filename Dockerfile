# ===============================================================================
# Dockerfile para SymmetricDS en Render.com - VERSIÓN CORREGIDA
# ===============================================================================

FROM openjdk:17-jdk-slim

# Variables de entorno
ENV JAVA_OPTS="-Xmx512m -Xms256m -Djava.awt.headless=true"
ENV SYMMETRIC_HOME="/app"
ENV PORT=8080
ENV PG_PORT=5432

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar archivos
COPY . .

# Permisos
RUN chmod +x bin/* && \
    mkdir -p logs tmp engines security

# Crear script de entrada
RUN echo '#!/bin/bash' > /app/docker-entrypoint.sh && \
    echo 'set -e' >> /app/docker-entrypoint.sh && \
    echo 'echo "🚀 Iniciando SymmetricDS Master Node..."' >> /app/docker-entrypoint.sh && \
    echo 'echo "📅 Fecha: $(date)"' >> /app/docker-entrypoint.sh && \
    echo 'if [ -z "$PG_HOST" ] || [ -z "$PG_USER" ] || [ -z "$PG_PASS" ]; then' >> /app/docker-entrypoint.sh && \
    echo '    echo "❌ ERROR: Variables PostgreSQL faltantes"' >> /app/docker-entrypoint.sh && \
    echo '    exit 1' >> /app/docker-entrypoint.sh && \
    echo 'fi' >> /app/docker-entrypoint.sh && \
    echo 'export PG_PORT=${PG_PORT:-5432}' >> /app/docker-entrypoint.sh && \
    echo 'export PG_DB=${PG_DB:-postgres}' >> /app/docker-entrypoint.sh && \
    echo 'echo "✅ Variables configuradas:"' >> /app/docker-entrypoint.sh && \
    echo 'echo "   - PG_HOST: $PG_HOST"' >> /app/docker-entrypoint.sh && \
    echo 'echo "   - PG_USER: $PG_USER"' >> /app/docker-entrypoint.sh && \
    echo 'echo "   - PORT: $PORT"' >> /app/docker-entrypoint.sh && \
    echo 'echo "   - RENDER_EXTERNAL_URL: $RENDER_EXTERNAL_URL"' >> /app/docker-entrypoint.sh && \
    echo 'CONFIG_FILE="/app/engines/supabase-server.properties"' >> /app/docker-entrypoint.sh && \
    echo 'mkdir -p /app/engines' >> /app/docker-entrypoint.sh && \
    echo 'cat > "$CONFIG_FILE" << EOF' >> /app/docker-entrypoint.sh && \
    echo 'engine.name=supabase-server' >> /app/docker-entrypoint.sh && \
    echo 'group.id=master' >> /app/docker-entrypoint.sh && \
    echo 'external.id=supabase-001' >> /app/docker-entrypoint.sh && \
    echo 'sync.url=${RENDER_EXTERNAL_URL}/sync/supabase-server' >> /app/docker-entrypoint.sh && \
    echo 'registration.url=${RENDER_EXTERNAL_URL}/sync/supabase-server' >> /app/docker-entrypoint.sh && \
    echo 'db.driver=org.postgresql.Driver' >> /app/docker-entrypoint.sh && \
    echo 'db.url=jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}?sslmode=require&ssl=true&connectTimeout=30&socketTimeout=60' >> /app/docker-entrypoint.sh && \
    echo 'db.user=${PG_USER}' >> /app/docker-entrypoint.sh && \
    echo 'db.password=${PG_PASS}' >> /app/docker-entrypoint.sh && \
    echo 'db.pool.initial.size=2' >> /app/docker-entrypoint.sh && \
    echo 'db.pool.max.size=10' >> /app/docker-entrypoint.sh && \
    echo 'db.pool.test.on.borrow=true' >> /app/docker-entrypoint.sh && \
    echo 'db.pool.validation.query=SELECT 1' >> /app/docker-entrypoint.sh && \
    echo 'auto.registration=false' >> /app/docker-entrypoint.sh && \
    echo 'start.route.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.outgoing.batches.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.incoming.batches.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.statistics.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.synctriggers.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.push.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.pull.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.heartbeat.job=true' >> /app/docker-entrypoint.sh && \
    echo 'start.purge.job=true' >> /app/docker-entrypoint.sh && \
    echo 'web.enable=true' >> /app/docker-entrypoint.sh && \
    echo 'web.http.port=${PORT}' >> /app/docker-entrypoint.sh && \
    echo 'web.context.path=/sync' >> /app/docker-entrypoint.sh && \
    echo 'log.level=INFO' >> /app/docker-entrypoint.sh && \
    echo 'console.log.level=INFO' >> /app/docker-entrypoint.sh && \
    echo 'auto.config.database=true' >> /app/docker-entrypoint.sh && \
    echo 'auto.config.registration=true' >> /app/docker-entrypoint.sh && \
    echo 'EOF' >> /app/docker-entrypoint.sh && \
    echo 'echo "✅ Configuración creada: $CONFIG_FILE"' >> /app/docker-entrypoint.sh && \
    echo 'export SYMMETRIC_HOME="/app"' >> /app/docker-entrypoint.sh && \
    echo 'export SYM_HOME="/app"' >> /app/docker-entrypoint.sh && \
    echo 'cd /app' >> /app/docker-entrypoint.sh && \
    echo 'echo "🎯 Iniciando SymmetricDS usando symadmin..."' >> /app/docker-entrypoint.sh && \
    echo 'echo "🔧 Inicializando base de datos..."' >> /app/docker-entrypoint.sh && \
    echo 'bin/symadmin --engine supabase-server create-sym-tables 2>/dev/null || echo "Tablas ya existen"' >> /app/docker-entrypoint.sh && \
    echo 'echo "🚀 Iniciando servicio SymmetricDS..."' >> /app/docker-entrypoint.sh && \
    echo 'exec bin/sym --engine supabase-server --port ${PORT}' >> /app/docker-entrypoint.sh

# Hacer ejecutable
RUN chmod +x /app/docker-entrypoint.sh

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:$PORT/sync/supabase-server || exit 1

# Punto de entrada
ENTRYPOINT ["/app/docker-entrypoint.sh"]