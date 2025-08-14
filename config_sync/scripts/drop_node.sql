-- ===============================================================================
-- drop_node.sql - Script para dar de baja una sucursal
-- ===============================================================================
-- DESCRIPCIÓN: Script para eliminar completamente un nodo cliente del sistema
-- USO: Ejecutar en el nodo maestro PostgreSQL para eliminar una sucursal
-- 
-- PARÁMETROS A PERSONALIZAR:
-- - <EXTERNAL_ID>: ID de la sucursal a eliminar (ej: sucursal-001)
-- 
-- ⚠️  ADVERTENCIA: Esta operación es IRREVERSIBLE
-- ===============================================================================

-- ===============================================================================
-- PASO 1: Verificación de seguridad
-- ===============================================================================
DO $$
DECLARE
    node_exists INTEGER;
    pending_batches INTEGER;
    last_heartbeat TIMESTAMP;
BEGIN
    -- Verificar que el nodo existe
    SELECT COUNT(*) INTO node_exists 
    FROM sym_node 
    WHERE external_id = '<EXTERNAL_ID>';
    
    IF node_exists = 0 THEN
        RAISE EXCEPTION 'El nodo % no existe en el sistema.', '<EXTERNAL_ID>';
    END IF;
    
    -- Verificar batches pendientes
    SELECT COUNT(*) INTO pending_batches
    FROM sym_outgoing_batch 
    WHERE node_id = '<EXTERNAL_ID>' 
    AND status IN ('NE', 'QY', 'SE', 'LD', 'ER');
    
    -- Obtener último heartbeat
    SELECT heartbeat_time INTO last_heartbeat
    FROM sym_node 
    WHERE external_id = '<EXTERNAL_ID>';
    
    RAISE NOTICE 'Nodo encontrado: %', '<EXTERNAL_ID>';
    RAISE NOTICE 'Batches pendientes: %', pending_batches;
    RAISE NOTICE 'Último heartbeat: %', last_heartbeat;
    
    IF pending_batches > 0 THEN
        RAISE WARNING 'El nodo tiene % batches pendientes. Se eliminarán junto con el nodo.', pending_batches;
    END IF;
    
    RAISE NOTICE 'Procediendo con la eliminación del nodo...';
END $$;

-- ===============================================================================
-- PASO 2: Deshabilitar el nodo (por seguridad)
-- ===============================================================================
UPDATE sym_node 
SET sync_enabled = 0,
    last_update_time = current_timestamp
WHERE external_id = '<EXTERNAL_ID>';

UPDATE sym_node_security
SET registration_enabled = 0,
    initial_load_enabled = 0,
    last_update_time = current_timestamp
WHERE node_id = '<EXTERNAL_ID>';

-- ===============================================================================
-- PASO 3: Limpiar datos relacionados con el nodo
-- ===============================================================================

-- Eliminar batches salientes
DELETE FROM sym_data_event 
WHERE batch_id IN (
    SELECT batch_id FROM sym_outgoing_batch 
    WHERE node_id = '<EXTERNAL_ID>'
);

DELETE FROM sym_outgoing_batch 
WHERE node_id = '<EXTERNAL_ID>';

-- Eliminar batches entrantes
DELETE FROM sym_incoming_batch 
WHERE node_id = '<EXTERNAL_ID>';

-- Eliminar estadísticas del nodo
DELETE FROM sym_node_communication 
WHERE node_id = '<EXTERNAL_ID>';

-- Eliminar control de canales
DELETE FROM sym_node_channel_ctl 
WHERE node_id = '<EXTERNAL_ID>';

-- Eliminar locks
DELETE FROM sym_lock 
WHERE locking_server_id = '<EXTERNAL_ID>';

-- Eliminar estadísticas
DELETE FROM sym_table_reload_status 
WHERE target_node_id = '<EXTERNAL_ID>' 
OR source_node_id = '<EXTERNAL_ID>';

-- Eliminar historial de heartbeat
DELETE FROM sym_node_heartbeat 
WHERE node_id = '<EXTERNAL_ID>';

-- ===============================================================================
-- PASO 4: Eliminar configuración del nodo
-- ===============================================================================

-- Eliminar seguridad del nodo
DELETE FROM sym_node_security 
WHERE node_id = '<EXTERNAL_ID>';

-- Eliminar identidad del nodo
DELETE FROM sym_node_identity 
WHERE node_id = '<EXTERNAL_ID>';

-- ===============================================================================
-- PASO 5: Eliminar el nodo principal
-- ===============================================================================
DELETE FROM sym_node 
WHERE external_id = '<EXTERNAL_ID>';

-- ===============================================================================
-- PASO 6: Limpiar referencias órfanas (opcional pero recomendado)
-- ===============================================================================

-- Limpiar data events sin batch
DELETE FROM sym_data_event 
WHERE batch_id NOT IN (
    SELECT DISTINCT batch_id FROM sym_outgoing_batch
    UNION
    SELECT DISTINCT batch_id FROM sym_incoming_batch
);

-- Limpiar datos huérfanos en tablas relacionadas
DELETE FROM sym_extract_request 
WHERE node_id = '<EXTERNAL_ID>';

-- ===============================================================================
-- PASO 7: Verificación de eliminación
-- ===============================================================================
DO $$
DECLARE
    remaining_records INTEGER := 0;
    table_name TEXT;
    sql_query TEXT;
    tables_to_check TEXT[] := ARRAY[
        'sym_node',
        'sym_node_security', 
        'sym_node_identity',
        'sym_node_communication',
        'sym_node_channel_ctl',
        'sym_outgoing_batch',
        'sym_incoming_batch',
        'sym_extract_request',
        'sym_lock',
        'sym_table_reload_status',
        'sym_node_heartbeat'
    ];
BEGIN
    RAISE NOTICE 'Verificando eliminación completa del nodo %...', '<EXTERNAL_ID>';
    
    FOREACH table_name IN ARRAY tables_to_check
    LOOP
        sql_query := format('SELECT COUNT(*) FROM %I WHERE node_id = $1 OR external_id = $1 OR target_node_id = $1 OR source_node_id = $1 OR locking_server_id = $1', table_name);
        
        BEGIN
            EXECUTE sql_query INTO remaining_records USING '<EXTERNAL_ID>';
            
            IF remaining_records > 0 THEN
                RAISE WARNING 'Tabla % todavía contiene % registros relacionados con el nodo', table_name, remaining_records;
            ELSE
                RAISE NOTICE 'Tabla % limpia ✓', table_name;
            END IF;
        EXCEPTION
            WHEN undefined_column THEN
                RAISE NOTICE 'Tabla % no contiene columnas relevantes, saltando...', table_name;
        END;
    END LOOP;
    
    RAISE NOTICE 'Verificación completada.';
END $$;

-- ===============================================================================
-- PASO 8: Resumen final
-- ===============================================================================
SELECT 
    'ELIMINACIÓN COMPLETADA' as status,
    '<EXTERNAL_ID>' as nodo_eliminado,
    current_timestamp as fecha_eliminacion,
    (SELECT COUNT(*) FROM sym_node WHERE node_group_id = 'client') as nodos_cliente_restantes;

-- Mostrar nodos restantes
SELECT 
    'NODOS ACTIVOS RESTANTES' as status,
    node_id,
    external_id,
    node_group_id,
    sync_enabled,
    created_at
FROM sym_node
WHERE node_group_id = 'client'
ORDER BY created_at;

-- ===============================================================================
-- INSTRUCCIONES FINALES
-- ===============================================================================
/*
ELIMINACIÓN COMPLETADA:

El nodo <EXTERNAL_ID> ha sido eliminado completamente del sistema.

PASOS ADICIONALES EN LA SUCURSAL:

1. Detener el servicio SymmetricDS en la sucursal:
   bin/sym_service -engine config_sync/engines/local-client.properties stop

2. (Opcional) Limpiar base de datos local:
   - Eliminar tablas sym_* si no planea reconectar
   - Hacer backup de datos de negocio si es necesario

3. (Opcional) Eliminar archivos de configuración:
   - Eliminar config_sync/engines/local-client.properties personalizado
   - Limpiar directorio logs/

PARA RECONECTAR LA SUCURSAL:

1. Usar register_new_node.sql con un nuevo external_id
2. Configurar nuevo archivo local-client.properties
3. Realizar initial load completo

IMPORTANTE: 
- Esta eliminación es irreversible
- Los datos de sincronización se han perdido permanentemente
- La sucursal necesitará re-registro completo para volver a conectarse

NODOS RESTANTES: Ver resultado de la consulta anterior
*/
