-- ===============================================================================
-- register_new_node.sql - Script para registrar una nueva sucursal
-- ===============================================================================
-- DESCRIPCIÓN: Script para dar de alta un nuevo nodo cliente (sucursal)
-- USO: Ejecutar en el nodo maestro PostgreSQL antes de conectar una nueva sucursal
-- 
-- PARÁMETROS A PERSONALIZAR:
-- - <EXTERNAL_ID>: ID de la sucursal (ej: sucursal-001, sucursal-002, etc.)
-- - <NODE_PASSWORD>: Password único para esta sucursal
-- - <DESCRIPCION>: Descripción de la sucursal
-- ===============================================================================

-- ===============================================================================
-- PASO 1: Verificar que no existe el nodo
-- ===============================================================================
DO $$
DECLARE
    node_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO node_exists 
    FROM sym_node 
    WHERE external_id = '<EXTERNAL_ID>';
    
    IF node_exists > 0 THEN
        RAISE EXCEPTION 'El nodo % ya existe. Use drop_node.sql primero si desea recrearlo.', '<EXTERNAL_ID>';
    END IF;
    
    RAISE NOTICE 'Procediendo con el registro del nodo %', '<EXTERNAL_ID>';
END $$;

-- ===============================================================================
-- PASO 2: Registrar el nuevo nodo
-- ===============================================================================
INSERT INTO sym_node 
(node_id, node_group_id, external_id, sync_enabled, sync_url, schema_version, symmetric_version, database_type, database_version, heartbeat_time, timezone_offset, batch_to_send_count, batch_in_error_count, created_at, deployment_type) 
VALUES
('<EXTERNAL_ID>', 'client', '<EXTERNAL_ID>', 1, null, '3.16.5', '3.16.5', 'mysql', '8.0', current_timestamp, '+00:00', 0, 0, current_timestamp, 'client');

-- ===============================================================================
-- PASO 3: Configurar seguridad del nodo
-- ===============================================================================
INSERT INTO sym_node_security 
(node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at, rev_initial_load_enabled, rev_initial_load_time) 
VALUES
('<EXTERNAL_ID>', '<NODE_PASSWORD>', 1, current_timestamp, 1, current_timestamp, current_timestamp, 1, current_timestamp);

-- ===============================================================================
-- PASO 4: Programar initial load automático
-- ===============================================================================
-- El initial load se creará automáticamente cuando el nodo se conecte por primera vez
-- Pero podemos forzarlo manualmente si es necesario:

INSERT INTO sym_node_communication 
(node_id, communication_type, lock_time, success_count, total_success_count, total_success_millis, fail_count, total_fail_count, total_fail_millis, skip_count, last_lock_time, last_lock_millis) 
VALUES
('<EXTERNAL_ID>', 'pull', null, 0, 0, 0, 0, 0, 0, 0, null, 0),
('<EXTERNAL_ID>', 'push', null, 0, 0, 0, 0, 0, 0, 0, null, 0);

-- ===============================================================================
-- PASO 5: Configurar canales para el nodo
-- ===============================================================================
INSERT INTO sym_node_channel_ctl 
(node_id, channel_id, suspend_enabled, ignore_enabled, last_extract_time, created_at, last_update_time)
SELECT '<EXTERNAL_ID>', c.channel_id, 0, 0, '1970-01-01 00:00:00', current_timestamp, current_timestamp
FROM sym_channel c
WHERE c.channel_id IN ('dml', 'config', 'files', 'heartbeat');

-- ===============================================================================
-- PASO 6: Crear initial load request para todas las tablas
-- ===============================================================================
-- Esto forzará que el nodo reciba todos los datos al conectarse
DO $$
DECLARE
    batch_id VARCHAR(50);
BEGIN
    -- Generar ID único para el batch
    batch_id := 'initial-load-' || '<EXTERNAL_ID>' || '-' || extract(epoch from current_timestamp)::bigint;
    
    -- Crear batch de initial load
    INSERT INTO sym_outgoing_batch 
    (batch_id, node_id, channel_id, status, batch_type, extract_count, sent_count, load_count, data_event_count, reload_event_count, insert_event_count, update_event_count, delete_event_count, other_event_count, ignore_count, router_millis, network_millis, filter_millis, load_millis, extract_millis, sql_state, sql_code, sql_message, failed_data_id, last_update_hostname, last_update_time, create_time, extract_job_flag, load_flag, error_flag, common_flag, skip_count, total_extract_millis, total_load_millis, extract_start_time, transfer_start_time, load_start_time, extract_end_time, transfer_end_time, load_end_time, create_by)
    VALUES
    (batch_id, '<EXTERNAL_ID>', 'reload', 'NE', 'I', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, null, null, null, current_timestamp, current_timestamp, 0, 0, 0, 0, 0, 0, 0, null, null, null, null, null, null, 'register_new_node.sql');
    
    RAISE NOTICE 'Batch de initial load creado: %', batch_id;
END $$;

-- ===============================================================================
-- PASO 7: Verificación del registro
-- ===============================================================================
SELECT 
    'NODO REGISTRADO EXITOSAMENTE' as status,
    n.node_id,
    n.external_id,
    n.node_group_id,
    n.sync_enabled,
    ns.registration_enabled,
    ns.initial_load_enabled,
    n.created_at
FROM sym_node n
JOIN sym_node_security ns ON n.node_id = ns.node_id
WHERE n.external_id = '<EXTERNAL_ID>';

-- Verificar canales configurados
SELECT 
    'CANALES CONFIGURADOS' as status,
    ncc.node_id,
    ncc.channel_id,
    ncc.suspend_enabled,
    ncc.ignore_enabled
FROM sym_node_channel_ctl ncc
WHERE ncc.node_id = '<EXTERNAL_ID>'
ORDER BY ncc.channel_id;

-- Verificar batches pendientes
SELECT 
    'BATCHES PENDIENTES' as status,
    ob.batch_id,
    ob.node_id,
    ob.channel_id,
    ob.status,
    ob.batch_type,
    ob.create_time
FROM sym_outgoing_batch ob
WHERE ob.node_id = '<EXTERNAL_ID>'
ORDER BY ob.create_time DESC
LIMIT 5;

-- ===============================================================================
-- INSTRUCCIONES SIGUIENTES
-- ===============================================================================
/*
PRÓXIMOS PASOS:

1. El nodo ha sido registrado exitosamente en el servidor maestro.

2. En la sucursal, editar el archivo local-client.properties:
   - Cambiar external.id=<EXTERNAL_ID>
   - Cambiar db.url con el nombre de la base de datos local
   - Verificar sync.url apunta al servidor maestro

3. Iniciar el servicio SymmetricDS en la sucursal:
   bin/sym_service -engine config_sync/engines/local-client.properties start

4. Verificar logs para confirmar conexión exitosa:
   tail -f logs/symmetric.log

5. El initial load comenzará automáticamente al establecer la conexión.

6. Usar verify_health.sql para monitorear el estado de sincronización.

DATOS DEL NODO:
- External ID: <EXTERNAL_ID>
- Password: <NODE_PASSWORD>
- Grupo: client
- Estado: Habilitado para sincronización e initial load

IMPORTANTE: Guarde estos datos de forma segura.
*/
