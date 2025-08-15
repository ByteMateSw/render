# 🏢 GUÍA DE CONFIGURACIÓN - SUCURSAL 001
## SymmetricDS Cliente MySQL Local

### 📋 **REQUISITOS PREVIOS**

✅ **MySQL instalado y funcionando**
- Versión: 5.7+ o 8.0+
- Puerto: 3306
- Usuario: root
- Password: aps22

✅ **Servidor maestro funcionando**
- URL: https://symmetricds-j1ak.onrender.com/sync/supabase-server
- Estado: ONLINE ✅
- 30 tablas bidireccionales configuradas ✅

✅ **SymmetricDS local**
- Versión: 3.16.5
- Ubicación: C:\Users\Estudiante\Desktop\symmetric-server-3.16.5\

---

## 🗄️ **PASO 1: CREAR BASE DE DATOS MYSQL**

### 1.1 Conectarse a MySQL
```bash
mysql -u root -p
# Password: aps22
```

### 1.2 Ejecutar script de creación
```sql
-- Ejecutar todo el contenido del archivo:
source C:/Users/Estudiante/Desktop/symmetric-server-3.16.5/config_sync/sucursal-1/sql/00-create-database.sql
```

### 1.3 Verificar creación exitosa
```sql
USE sucursal_001;
SHOW TABLES;
-- Debería mostrar 30 tablas creadas
```

---

## 🔐 **PASO 2: REGISTRAR SUCURSAL EN SERVIDOR MAESTRO**

### 2.1 Ir a Supabase SQL Editor
- URL: https://supabase.com/dashboard/project/[tu-proyecto]
- Sección: SQL Editor

### 2.2 Ejecutar script de registro
```sql
-- Copiar y ejecutar el contenido de:
-- config_sync/sucursal-1/sql/01-register-branch.sql

INSERT INTO sym_node_security 
(node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at_node_id)
VALUES 
('sucursal-001', 'sucursal-password-2024', 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 'supabase-001');
```

### 2.3 Verificar registro
```sql
SELECT node_id, registration_enabled, initial_load_enabled 
FROM sym_node_security 
WHERE node_id = 'sucursal-001';
```

---

## ⚙️ **PASO 3: CONFIGURAR SYMMETRICDS LOCAL**

### 3.1 Copiar archivo de configuración
```bash
# Copiar el archivo de configuración a la carpeta engines de SymmetricDS
copy "C:\Users\Estudiante\Desktop\symmetric-server-3.16.5\config_sync\sucursal-1\engines\sucursal-001.properties" "C:\Users\Estudiante\Desktop\symmetric-server-3.16.5\engines\"
```

### 3.2 Verificar configuración
```bash
# Verificar que el archivo existe
dir "C:\Users\Estudiante\Desktop\symmetric-server-3.16.5\engines\sucursal-001.properties"
```

---

## 🚀 **PASO 4: INICIAR SYMMETRICDS EN SUCURSAL**

### 4.1 Abrir PowerShell como Administrador
```powershell
cd "C:\Users\Estudiante\Desktop\symmetric-server-3.16.5"
```

### 4.2 Iniciar SymmetricDS
```powershell
.\bin\sym --engine sucursal-001 --port 8081
```

### 4.3 Logs esperados al iniciar
```
[sucursal-001] - SymmetricDS is starting...
[sucursal-001] - Attempting to register with master...
[sucursal-001] - Registration successful
[sucursal-001] - Initial load starting...
[sucursal-001] - Creating triggers for 30 tables...
[sucursal-001] - Synchronization is active
[sucursal-001] - Web console available at http://localhost:8081/sync
```

---

## 🔍 **PASO 5: VERIFICAR FUNCIONAMIENTO**

### 5.1 Verificar conexión web
- Abrir navegador en: http://localhost:8081/sync
- Debería mostrar la consola de SymmetricDS

### 5.2 Verificar en base de datos
```sql
USE sucursal_001;

-- Verificar que se crearon tablas SymmetricDS
SHOW TABLES LIKE 'sym_%';

-- Verificar registro del nodo
SELECT * FROM sym_node WHERE external_id = 'sucursal-001';

-- Verificar triggers creados
SELECT COUNT(*) as total_triggers FROM sym_trigger;
-- Debería mostrar 30 triggers
```

### 5.3 Verificar sincronización
```sql
-- Verificar estado de sincronización
SELECT 
    'Outgoing Batches' as tipo,
    COUNT(*) as cantidad 
FROM sym_outgoing_batch
UNION ALL
SELECT 
    'Incoming Batches',
    COUNT(*) 
FROM sym_incoming_batch;
```

---

## ✅ **ESTADO ESPERADO DESPUÉS DE LA CONFIGURACIÓN**

### **En MySQL (Sucursal):**
- ✅ 30 tablas de aplicación creadas
- ✅ ~70 tablas SymmetricDS creadas
- ✅ 30 triggers configurados
- ✅ Nodo sucursal-001 registrado

### **En PostgreSQL (Maestro):**
- ✅ Sucursal registrada en sym_node_security
- ✅ Nuevo nodo visible en sym_node

### **En SymmetricDS:**
- ✅ Sincronización bidireccional activa
- ✅ Jobs ejecutándose cada 10 segundos
- ✅ Web console accesible

---

## 🔧 **TROUBLESHOOTING**

### **Error: "Registration failed"**
- Verificar que el servidor maestro esté online
- Verificar que se ejecutó el script de registro en Supabase
- Verificar conectividad a internet

### **Error: "Database connection failed"**
- Verificar que MySQL esté ejecutándose
- Verificar credenciales (root/aps22)
- Verificar que la base sucursal_001 existe

### **Error: "Port 8081 already in use"**
- Cambiar puerto en sucursal-001.properties
- O cerrar aplicación que usa el puerto 8081

---

## 📞 **SOPORTE**

Si hay problemas, revisar los logs en:
- `logs/symmetric.log`
- Consola web: http://localhost:8081/sync
- Servidor maestro: https://symmetricds-j1ak.onrender.com/sync/supabase-server

---

**¡Configuración completa! La Sucursal 001 está lista para sincronizar con el servidor maestro. 🎉**
