# 🚀 GUÍA DE DESPLIEGUE EN RENDER.COM

## 📋 Resumen Ejecutivo

Esta guía te lleva paso a paso para desplegar SymmetricDS como servicio web en Render.com usando Docker.

---

## 📦 Paso 1: Preparar el Repositorio

### Opción A: Subir ZIP a GitHub

1. **Crear repositorio en GitHub** (público o privado)
2. **Subir TODO el contenido** de `symmetric-server-3.16.5/` 
3. **Verificar que incluye**:
   ```
   ├── Dockerfile ✅
   ├── .dockerignore ✅
   ├── bin/ ✅
   ├── lib/ ✅
   ├── web/ ✅
   ├── config_sync/ ✅
   └── [resto de archivos SymmetricDS]
   ```

### Opción B: Git directo
```bash
cd symmetric-server-3.16.5
git init
git add .
git commit -m "SymmetricDS para Render.com"
git remote add origin https://github.com/TUUSUARIO/TUREPO.git
git push -u origin main
```

---

## 🌐 Paso 2: Configurar Servicio en Render.com

### 2.1 Crear Nuevo Servicio

1. **Ir a** [dashboard.render.com](https://dashboard.render.com)
2. **Clic en** "New +" → "Web Service"
3. **Conectar repositorio** GitHub creado en Paso 1

### 2.2 Configuración Básica

```yaml
# En el formulario de Render.com:
Name: symmetricds-master
Environment: Docker
Region: Oregon (US West) # o la más cercana
Branch: main
```

### 2.3 Configuración Docker

```yaml
# Build & Deploy:
Build Command: [Vacío - usa Dockerfile]
Start Command: [Vacío - usa Dockerfile ENTRYPOINT]
```

### 2.4 Plan y Configuración

```yaml
Instance Type: Starter ($7/month) o Standard ($25/month)
Auto-Deploy: Yes
```

---

## ⚙️ Paso 3: Variables de Entorno

**EN RENDER.COM DASHBOARD → Environment Variables:**

### 🔑 Variables OBLIGATORIAS:

```bash
# Base de Datos PostgreSQL (para nodo maestro)
PG_HOST=tu-postgres-host.com
PG_PORT=5432
PG_DB=nombre_base_datos
PG_USER=tu_usuario
PG_PASS=tu_password_seguro

# Configuración Java
JAVA_OPTS=-Xmx512m -Xms256m -Djava.awt.headless=true

# Puerto (automático en Render.com)
PORT=8080
```

### 🏪 Variables OPCIONALES para Sucursales MySQL:

```bash
# Base de Datos MySQL (para sucursales)
MYSQL_HOST=tu-mysql-host.com
MYSQL_PORT=3306
MYSQL_DB=sucursal_001
MYSQL_USER=tu_usuario_mysql
MYSQL_PASS=tu_password_mysql
```

### 🌍 Variables OPCIONALES:

```bash
# Zona horaria
TZ=America/Argentina/Buenos_Aires

# Engine personalizado (por defecto usa render-server.properties)
SYMMETRIC_ENGINE=config_sync/engines/render-server.properties
```

---

## 📊 Paso 4: Configurar Base de Datos PostgreSQL

### Si usas Render PostgreSQL:

1. **Crear** PostgreSQL database en Render.com
2. **Copiar** connection details
3. **Configurar** variables de entorno arriba

### Si usas otro proveedor (Supabase, AWS RDS, etc.):

```bash
# Ejemplo Supabase:
PG_HOST=db.xxxxxxxxxxxx.supabase.co
PG_PORT=5432
PG_DB=postgres
PG_USER=postgres
PG_PASS=tu_password_supabase
```

**⚠️ IMPORTANTE:** La base debe tener SSL habilitado

---

## 🚀 Paso 5: Deploy

### 5.1 Iniciar Deploy

1. **Clic** "Create Web Service"
2. **Esperar** el build (5-10 minutos)
3. **Verificar logs** en tiempo real

### 5.2 Verificar Deploy Exitoso

**Buscar en logs:**
```
🚀 Iniciando SymmetricDS Master Node...
✅ Archivo de configuración encontrado
🎯 Ejecutando comando: bin/sym_service...
Started SymmetricDS web server
Registration opened
```

### 5.3 Obtener URL

Render.com asigna automáticamente:
```
https://tu-app-name.onrender.com
```

**URL de sincronización será:**
```
https://tu-app-name.onrender.com/sync/supabase-server
```

---

## ✅ Paso 6: Verificar Funcionamiento

### 6.1 Test de Health Check

```bash
curl https://tu-app-name.onrender.com/sync/supabase-server
```

**Debe responder:** Página de estado de SymmetricDS

### 6.2 Test de Registro

```bash
curl https://tu-app-name.onrender.com/sync/supabase-server/registration
```

**Debe responder:** XML de registro de nodos

---

## 📋 Paso 7: Configurar Base de Datos (SQL)

### 7.1 Conectar a PostgreSQL

```bash
# Si usas Render PostgreSQL, usar External Database URL
psql "postgresql://usuario:pass@host:port/db?sslmode=require"
```

### 7.2 Ejecutar Scripts en Orden

```sql
-- EJECUTAR EN ESTE ORDEN EXACTO:
\i config_sync/sql/00_channels.sql
\i config_sync/sql/01_node_groups_and_links.sql
\i config_sync/sql/02_routers.sql
\i config_sync/sql/03_triggers_from_tables_js.sql
\i config_sync/sql/04_trigger_router_map.sql
\i config_sync/sql/05_node_security_seed.sql
```

**⚠️ ANTES DE EJECUTAR:** Actualizar los placeholders en `05_node_security_seed.sql`:
- Reemplazar `<TU_DOMINIO>` con tu URL real de Render.com

---

## 🔧 Troubleshooting

### Problema: "Build Failed"

**Solución:**
```bash
# Verificar que existe:
- Dockerfile en raíz ✅
- bin/ directory con permisos ✅
- lib/ directory con JARs ✅
```

### Problema: "Database Connection Failed"

**Verificar:**
```bash
# Variables de entorno:
echo $PG_HOST
echo $PG_USER
echo $PG_PASS

# SSL habilitado en PostgreSQL ✅
# Firewall permite conexiones desde Render.com ✅
```

### Problema: "Service Unhealthy"

**Ver logs:**
```bash
# En Render.com Dashboard → Logs
# Buscar errores específicos
```

### Problema: "URL no responde"

**Verificar:**
```bash
# Puerto correcto (8080) ✅
# Health check configurado ✅
# Servicio completamente iniciado (puede tomar 2-3 min) ✅
```

---

## 📈 Monitoreo Continuo

### Logs en Tiempo Real

**En Render.com Dashboard → Logs:**
```
🔍 Buscar:
- "ERROR" para errores
- "Started" para inicio exitoso
- "Registration" para conexiones de nodos
```

### Métricas

**En Render.com Dashboard → Metrics:**
- CPU usage
- Memory usage  
- Response time
- Request volume

### Base de Datos

```sql
-- Verificar salud del sistema
\i config_sync/scripts/verify_health.sql
```

---

## 🎯 Checklist Final

### Pre-Deploy:
- [ ] Repositorio GitHub con todos los archivos
- [ ] Dockerfile y .dockerignore presentes
- [ ] Variables de entorno configuradas
- [ ] Base de datos PostgreSQL con SSL

### Post-Deploy:
- [ ] Build exitoso sin errores
- [ ] Servicio "Live" en dashboard
- [ ] URL responde correctamente
- [ ] Scripts SQL ejecutados en orden
- [ ] Health check verde

### Validación:
- [ ] URL de sincronización accesible
- [ ] Registro de nodos funcionando
- [ ] Scripts verify_health.sql sin errores
- [ ] Primera sucursal conectada exitosamente

---

## 🔗 URLs Importantes

```bash
# Dashboard Render.com
https://dashboard.render.com

# Tu aplicación
https://tu-app-name.onrender.com

# Endpoint de sincronización  
https://tu-app-name.onrender.com/sync/supabase-server

# Endpoint de registro
https://tu-app-name.onrender.com/sync/supabase-server/registration
```

---

## 📞 Soporte

### Logs Útiles:
```bash
# En Render.com logs, buscar:
grep "ERROR" logs
grep "Failed" logs  
grep "Exception" logs
```

### Archivos Clave:
- `Dockerfile` - Configuración del contenedor
- `config_sync/engines/render-server.properties` - Config optimizada para Render
- `config_sync/sql/` - Scripts de inicialización DB

### Comandos de Debug:
```bash
# Verificar variables de entorno (en logs)
env | grep PG_

# Test de conectividad DB (en logs)
pg_isready -h $PG_HOST -p $PG_PORT
```

---

**🎉 ¡Tu SymmetricDS está listo en Render.com!**

Siguiente paso: Configurar tu primera sucursal siguiendo `README_operacion.md`
