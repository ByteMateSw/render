# SymmetricDS - Guía Completa de Operación
## Sincronización MySQL ↔ PostgreSQL para Sistema de Sucursales

---

## 📋 Índice
1. [Prerequisitos](#prerequisitos)
2. [Despliegue del Maestro en Render.com](#despliegue-del-maestro-en-rendercom)
3. [Carga Inicial del Maestro](#carga-inicial-del-maestro)
4. [Alta de Sucursales](#alta-de-sucursales)
5. [Inicio de Servicios](#inicio-de-servicios)
6. [Validación y Monitoreo](#validación-y-monitoreo)
7. [Mantenimiento](#mantenimiento)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisitos

### Servidor Maestro (Render.com)
- ✅ **Java 17+** (OpenJDK recomendado)
- ✅ **PostgreSQL** en la nube con SSL habilitado
- ✅ **Plan Render.com** de pago básico o superior
- ✅ **Dominio personalizado** (ej: sync.midominio.com)

### Sucursales (Local)
- ✅ **Java 17+** (OpenJDK recomendado)
- ✅ **MySQL 8.0+** en localhost:3306
- ✅ **Conexión estable a Internet**
- ✅ **Acceso HTTPS** al servidor maestro

### Base de Datos PostgreSQL
```bash
# Ejemplo de cadena de conexión requerida
postgresql://usuario:password@host:5432/database?sslmode=require
```

---

## 🚀 Despliegue del Maestro en Render.com

### Paso 1: Preparar el Servicio

1. **Subir archivo ZIP** de SymmetricDS a Render.com
2. **Configurar variables de entorno**:

```bash
# Variables de entorno en Render.com
PG_HOST=tu-postgres-host.com
PG_PORT=5432
PG_DB=nombre_base_datos
PG_USER=usuario_postgres
PG_PASS=password_postgres
JAVA_OPTS=-Xmx1024m -Xms512m
```

3. **Configurar el servicio**:
   - **Build Command**: `chmod +x bin/*`
   - **Start Command**: `bin/sym_service -engine config_sync/engines/supabase-server.properties start`
   - **Port**: `8080`
   - **Health Check Path**: `/sync/supabase-server`

### Paso 2: Personalizar Configuración

Editar `config_sync/engines/supabase-server.properties`:

```properties
# Reemplazar placeholders con valores reales
db.url=jdbc:postgresql://TU_PG_HOST:5432/TU_DB?sslmode=require&ssl=true
db.user=TU_PG_USER
db.password=TU_PG_PASS
sync.url=https://tu-app-name.onrender.com/sync/supabase-server
web.base.url=https://tu-app-name.onrender.com
```

### Paso 3: Configurar Dominio (Opcional)

```bash
# En Render.com Dashboard > Settings > Custom Domains
# Agregar: sync.tudominio.com
# Configurar CNAME: tu-app-name.onrender.com
```

---

## 📊 Carga Inicial del Maestro

### Ejecutar Scripts SQL en Orden

**⚠️ IMPORTANTE**: Ejecutar en PostgreSQL del servidor maestro, **EN ESTE ORDEN**:

```sql
-- 1. CANALES
\i config_sync/sql/00_channels.sql

-- 2. GRUPOS Y ENLACES
\i config_sync/sql/01_node_groups_and_links.sql

-- 3. ROUTERS
\i config_sync/sql/02_routers.sql

-- 4. TRIGGERS (IMPORTANTE: personalizar antes)
\i config_sync/sql/03_triggers_from_tables_js.sql

-- 5. MAPEO TRIGGER-ROUTER
\i config_sync/sql/04_trigger_router_map.sql

-- 6. SEGURIDAD Y NODO MAESTRO (personalizar external.id)
\i config_sync/sql/05_node_security_seed.sql
```

### Verificar Carga Inicial

```sql
-- Verificar que todo se cargó correctamente
SELECT 'Canales' as tabla, COUNT(*) as registros FROM sym_channel
UNION ALL
SELECT 'Grupos', COUNT(*) FROM sym_node_group
UNION ALL
SELECT 'Routers', COUNT(*) FROM sym_router
UNION ALL
SELECT 'Triggers', COUNT(*) FROM sym_trigger
UNION ALL
SELECT 'Mapeos', COUNT(*) FROM sym_trigger_router
UNION ALL
SELECT 'Nodos', COUNT(*) FROM sym_node;
```

---

## 🏪 Alta de Sucursales

### Paso 1: Registrar Nueva Sucursal en Maestro

1. **Editar script de registro**:

```sql
-- Editar config_sync/scripts/register_new_node.sql
-- Reemplazar placeholders:
<EXTERNAL_ID> → sucursal-001
<NODE_PASSWORD> → password_seguro_sucursal_001
<DESCRIPCION> → Sucursal Centro - Buenos Aires
```

2. **Ejecutar en PostgreSQL maestro**:

```sql
\i config_sync/scripts/register_new_node.sql
```

### Paso 2: Configurar Cliente en Sucursal

1. **Copiar archivos** a la sucursal:
   - `config_sync/engines/local-client.properties`
   - Todo el directorio `config_sync/`

2. **Personalizar configuración**:

```properties
# En local-client.properties
external.id=sucursal-001
sync.url=https://tu-app-name.onrender.com/sync/supabase-server
db.url=jdbc:mysql://localhost:3306/mi_base_local?useSSL=false&serverTimezone=UTC
```

### Paso 3: Crear Base de Datos Local

```sql
-- En MySQL de la sucursal
CREATE DATABASE mi_base_local;
USE mi_base_local;

-- Ejecutar todos los CREATE TABLE del tables.js
-- (copiar y pegar las definiciones de tablas)
```

---

## ▶️ Inicio de Servicios

### Servidor Maestro (Render.com)

El servicio se inicia automáticamente. **Verificar logs**:

```bash
# En Render.com Dashboard > Logs
# Buscar líneas como:
# "SymmetricDS is starting up"
# "Started SymmetricDS web server"
# "Registration opened"
```

### Cliente Sucursal (Local)

```bash
# Navegar al directorio SymmetricDS
cd path/to/symmetric-server-3.16.5

# Iniciar servicio
bin/sym_service -engine config_sync/engines/local-client.properties start

# Verificar logs
tail -f logs/symmetric.log
```

### Comandos Útiles

```bash
# Detener servicio
bin/sym_service -engine config_sync/engines/local-client.properties stop

# Verificar estado
bin/sym_service -engine config_sync/engines/local-client.properties status

# Restart
bin/sym_service -engine config_sync/engines/local-client.properties restart
```

---

## ✅ Validación y Monitoreo

### Script de Verificación de Salud

**Ejecutar en PostgreSQL maestro**:

```sql
\i config_sync/scripts/verify_health.sql
```

Este script mostrará:
- 📊 Estado de todos los nodos
- 📦 Batches pendientes  
- ❌ Errores recientes
- 📈 Estadísticas de comunicación
- 🔄 Estado de initial loads

### Pruebas de Sincronización

#### Prueba 1: Maestro → Sucursal

```sql
-- En PostgreSQL (maestro)
INSERT INTO country (name) VALUES ('Argentina');

-- Verificar en MySQL (sucursal) después de ~30 segundos
SELECT * FROM country WHERE name = 'Argentina';
```

#### Prueba 2: Sucursal → Maestro

```sql
-- En MySQL (sucursal)  
INSERT INTO country (name) VALUES ('Chile');

-- Verificar en PostgreSQL (maestro) después de ~30 segundos
SELECT * FROM country WHERE name = 'Chile';
```

### Monitoreo Continuo

```sql
-- Ver batches pendientes
SELECT node_id, channel_id, status, COUNT(*) 
FROM sym_outgoing_batch 
WHERE status IN ('NE', 'QY', 'SE', 'LD', 'ER')
GROUP BY node_id, channel_id, status;

-- Ver errores recientes
SELECT node_id, sql_message, last_update_time 
FROM sym_outgoing_batch 
WHERE status = 'ER' 
ORDER BY last_update_time DESC 
LIMIT 10;
```

---

## 🔧 Mantenimiento

### Agregar Nueva Sucursal

1. **Registrar en maestro**:
   ```sql
   -- Personalizar y ejecutar
   \i config_sync/scripts/register_new_node.sql
   ```

2. **Configurar cliente** como se describió anteriormente

3. **Verificar conexión** con `verify_health.sql`

### Eliminar Sucursal

⚠️ **OPERACIÓN IRREVERSIBLE**

```sql
-- Editar external_id en el script
\i config_sync/scripts/drop_node.sql
```

### Editar Sucursal Existente

```sql
-- Cambiar URL de sincronización
UPDATE sym_node 
SET sync_url = 'nueva_url' 
WHERE external_id = 'sucursal-001';

-- Deshabilitar temporalmente
UPDATE sym_node 
SET sync_enabled = 0 
WHERE external_id = 'sucursal-001';

-- Reactivar
UPDATE sym_node 
SET sync_enabled = 1 
WHERE external_id = 'sucursal-001';
```

### Mantenimiento de Base de Datos

```sql
-- Limpiar batches antiguos (>7 días)
DELETE FROM sym_outgoing_batch 
WHERE create_time < (current_timestamp - interval '7 days')
AND status = 'OK';

-- Limpiar eventos antiguos
DELETE FROM sym_data_event 
WHERE create_time < (current_timestamp - interval '7 days');
```

---

## 🚨 Troubleshooting

### Problemas Comunes

#### 1. "Connection refused"
```bash
# Verificar:
- URL del maestro es accesible desde la sucursal
- Puerto 8080 abierto en Render.com
- SSL/HTTPS configurado correctamente
```

#### 2. "Initial load stuck"
```sql
-- Reiniciar initial load
DELETE FROM sym_table_reload_status WHERE target_node_id = 'sucursal-001';
UPDATE sym_node_security SET initial_load_enabled = 1 WHERE node_id = 'sucursal-001';
```

#### 3. "Batches con error permanente"
```sql
-- Limpiar batches erróneos
DELETE FROM sym_outgoing_batch WHERE status = 'ER' AND node_id = 'sucursal-001';
```

#### 4. "Tablas no sincronizando"
```sql
-- Recargar triggers
UPDATE sym_trigger SET last_update_time = current_timestamp;
```

### Logs Importantes

```bash
# En sucursal
tail -f logs/symmetric.log | grep -i error

# Buscar patrones específicos
grep "Failed to" logs/symmetric.log
grep "Exception" logs/symmetric.log
grep "Connection" logs/symmetric.log
```

### Comandos de Diagnóstico

```sql
-- Estado detallado de un nodo
SELECT * FROM sym_node WHERE external_id = 'sucursal-001';
SELECT * FROM sym_node_security WHERE node_id = 'sucursal-001';
SELECT * FROM sym_node_communication WHERE node_id = 'sucursal-001';

-- Batches problemáticos
SELECT * FROM sym_outgoing_batch 
WHERE node_id = 'sucursal-001' 
AND status = 'ER' 
ORDER BY create_time DESC;
```

---

## 📋 Checklist Final

### Pre-Despliegue
- [ ] PostgreSQL configurado con SSL
- [ ] Variables de entorno configuradas en Render.com
- [ ] Dominio personalizado configurado (opcional)
- [ ] Scripts SQL personalizados con valores reales

### Post-Despliegue
- [ ] Servicio maestro ejecutándose en Render.com
- [ ] Scripts SQL ejecutados en orden correcto
- [ ] Nodo maestro visible en `verify_health.sql`
- [ ] URL de registro accesible

### Por Cada Sucursal
- [ ] Nodo registrado en maestro con `register_new_node.sql`
- [ ] Base de datos MySQL creada con todas las tablas
- [ ] Archivo `local-client.properties` personalizado
- [ ] Servicio local iniciado correctamente
- [ ] Initial load completado
- [ ] Sincronización bidireccional funcionando

### Monitoreo Continuo
- [ ] Script `verify_health.sql` ejecutándose regularmente
- [ ] Alertas configuradas para batches con error
- [ ] Backup regular de configuración
- [ ] Logs monitoreados por errores

---

## 📞 Soporte

### Archivos de Configuración Clave
- `config_sync/engines/supabase-server.properties` - Maestro
- `config_sync/engines/local-client.properties` - Cliente template
- `config_sync/sql/` - Scripts de configuración
- `config_sync/scripts/` - Scripts de mantenimiento

### Comandos Esenciales
```bash
# Verificar estado
bin/sym_service -engine [config] status

# Ver logs en tiempo real  
tail -f logs/symmetric.log

# Reiniciar completamente
bin/sym_service -engine [config] stop
bin/sym_service -engine [config] start
```

### Validación Rápida
```sql
-- En maestro PostgreSQL
\i config_sync/scripts/verify_health.sql
```

---

**Fin de la Documentación**

*Esta guía cubre todos los aspectos de despliegue, configuración y mantenimiento del sistema SymmetricDS para sincronización entre MySQL local y PostgreSQL en la nube.*
