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
COPY <<EOF /app/docker-entrypoint.sh
#!/bin/bash
set -e

echo "🚀 Iniciando SymmetricDS Master Node..."
echo "📅 Fecha: \$(date)"

# Validar variables PostgreSQL
if [ -z "\$PG_HOST" ] || [ -z "\$PG_USER" ] || [ -z "\$PG_PASS" ]; then
    echo "❌ ERROR: Variables PostgreSQL faltantes"
    exit 1
fi

# Establecer valores por defecto
export PG_PORT=\${PG_PORT:-5432}
export PG_DB=\${PG_DB:-postgres}

echo "✅ Variables configuradas:"
echo "   - PG_HOST: \$PG_HOST"
echo "   - PG_USER: \$PG_USER"
echo "   - PORT: \$PORT"
echo "   - RENDER_EXTERNAL_URL: \$RENDER_EXTERNAL_URL"

# Crear configuración
CONFIG_FILE="/app/engines/supabase-server.properties"
mkdir -p /app/engines

cat > "$CONFIG_FILE" << CONFIG_EOF
engine.name=supabase-server
group.id=sucursal
external.id=sucursal-001
sync.url=\${RENDER_EXTERNAL_URL}/sync/supabase-server
registration.url=\${RENDER_EXTERNAL_URL}/sync/supabase-server

db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://\${PG_HOST}:\${PG_PORT}/\${PG_DB}?sslmode=require&ssl=true&connectTimeout=30&socketTimeout=60
db.user=\${PG_USER}
db.password=\${PG_PASS}

db.pool.initial.size=2
db.pool.max.size=10
db.pool.test.on.borrow=true
db.pool.validation.query=SELECT 1

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

web.enable=true
web.http.port=\${PORT}
web.context.path=/sync

log.level=INFO
console.log.level=INFO
auto.config.database=true
auto.config.registration=true
CONFIG_EOF

echo "✅ Configuración creada: \$CONFIG_FILE"

# Configurar entorno
export SYMMETRIC_HOME="/app"
export SYM_HOME="/app"
cd /app

echo "🎯 Iniciando SymmetricDS usando symadmin..."

# Usar symadmin para inicializar
echo "🔧 Inicializando base de datos..."
bin/symadmin --engine supabase-server create-sym-tables 2>/dev/null || echo "Tablas ya existen"

echo "🚀 Iniciando servicio SymmetricDS..."
# Usar sym directamente
exec bin/sym --engine supabase-server --port \${PORT}

EOF

# Hacer ejecutable
RUN chmod +x /app/docker-entrypoint.sh

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:$PORT/sync/supabase-server || exit 1

# Punto de entrada
ENTRYPOINT ["/app/docker-entrypoint.sh"]