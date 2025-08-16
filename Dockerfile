# ===============================================================================
# Dockerfile para SymmetricDS en Render.com - VERSIÓN CORREGIDA
# ===============================================================================

FROM openjdk:17-jdk-slim

# Variables de entorno
ENV JAVA_OPTS="-Xmx512m -Xms256m -Djava.awt.headless=true"
ENV SYMMETRIC_HOME="/app"
ENV PORT=8080
ENV PG_PORT=5432
ENV MYSQL_PORT=3306

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

# Validar variables MySQL si están presentes
if [ -n "\$MYSQL_HOST" ] && [ -z "\$MYSQL_USER" ]; then
    echo "❌ ERROR: MYSQL_HOST definido pero MYSQL_USER faltante"
    exit 1
fi

# Establecer valores por defecto
PG_PORT=\$\{PG_PORT:-5432\}
PG_DB=\$\{PG_DB:-postgres\}

# Establecer valores por defecto para MySQL
if [ -n "\$MYSQL_HOST" ]; then
    MYSQL_PORT=\$\{MYSQL_PORT:-3306\}
    MYSQL_DB=\$\{MYSQL_DB:-sucursal_001\}
fi

echo "✅ Variables configuradas:"
echo "   - PG_HOST: \$PG_HOST"
echo "   - PG_USER: \$PG_USER"
echo "   - PORT: \$PORT"
echo "   - RENDER_EXTERNAL_URL: \$RENDER_EXTERNAL_URL"
if [ -n "\$MYSQL_HOST" ]; then
    echo "   - MYSQL_HOST: \$MYSQL_HOST"
    echo "   - MYSQL_USER: \$MYSQL_USER"
fi

# Crear configuración
CONFIG_FILE="/app/engines/supabase-server.properties"
mkdir -p /app/engines

cat > "$CONFIG_FILE" << CONFIG_EOF
engine.name=supabase-server
group.id=sucursal
external.id=sucursal-001
sync.url=\$\{RENDER_EXTERNAL_URL\}/sync/supabase-server
registration.url=\$\{RENDER_EXTERNAL_URL\}/sync/supabase-server

db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://\$\{PG_HOST\}:\$\{PG_PORT\}/\$\{PG_DB\}?sslmode=require&ssl=true&connectTimeout=30&socketTimeout=60
db.user=\$\{PG_USER\}
db.password=\$\{PG_PASS\}

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
web.http.port=\$\{PORT\}
web.context.path=/sync

log.level=INFO
console.log.level=INFO
auto.config.database=true
auto.config.registration=true
CONFIG_EOF

echo "✅ Configuración creada: \$CONFIG_FILE"

# Crear configuración para sucursal-001 si hay variables MySQL
if [ -n "\$MYSQL_HOST" ]; then
    SUCURSAL_CONFIG_FILE="/app/engines/sucursal-001.properties"
    cat > "$SUCURSAL_CONFIG_FILE" << SUCURSAL_CONFIG_EOF
engine.name=sucursal-001
group.id=sucursal
external.id=sucursal-001

# Database Configuration - Using Environment Variables
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://\$\{MYSQL_HOST\}:\$\{MYSQL_PORT\}/\$\{MYSQL_DB\}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.user=\$\{MYSQL_USER\}
db.password=\$\{MYSQL_PASS\}

# Sync Configuration - Client connects to server
sync.url=\$\{RENDER_EXTERNAL_URL\}/sync/sucursal-001
registration.url=\$\{RENDER_EXTERNAL_URL\}/sync/supabase-server

# Client Configuration
auto.registration=true
auto.reload=true
start.push.job=true
start.pull.job=true
start.route.job=true
start.purge.job=true
start.heartbeat.job=true
start.synctriggers.job=true
start.watchdog.job=true
start.refresh.cache.job=true
start.file.sync.tracker.job=true
start.file.sync.push.job=true
start.file.sync.pull.job=true
start.stat.flush.job=true
start.offline.push.job=true
start.offline.pull.job=true
start.initial.load.extract.job=true

# Logging
log4j2.logger.symmetric.name=org.jumpmind.symmetric
log4j2.logger.symmetric.level=INFO
log4j2.logger.symmetric.additivity=false
log4j2.logger.symmetric.appenderRef.symmetric.ref=SYMMETRIC

# Performance
jmx.agent.enable=true
cluster.lock.enabled=false

# Data Gap Detection
data.gap.fast.detector.enabled=true
data.gap.fast.detector.threshold=50000

# Batch Processing
routing.largest.gap.size=50000000
SUCURSAL_CONFIG_EOF

    echo "✅ Configuración sucursal-001 creada: \$SUCURSAL_CONFIG_FILE"
fi

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
exec bin/sym --engine supabase-server --port \$\{PORT\}

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