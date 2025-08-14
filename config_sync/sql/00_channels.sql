-- ===============================================================================
-- 00_channels.sql - Configuración de Canales de Sincronización
-- ===============================================================================
-- DESCRIPCIÓN: Define los canales básicos para la sincronización de datos
-- EJECUCIÓN: Ejecutar PRIMER en el nodo maestro PostgreSQL

-- Canal para datos de gestión (DML - Insert, Update, Delete)
INSERT INTO sym_channel 
(channel_id, processing_order, max_batch_size, max_batch_to_send, extract_period_millis, batch_algorithm, enabled, description) 
VALUES
('dml', 1, 1000, 10, 0, 'default', 1, 'Canal para operaciones DML (Insert, Update, Delete) de datos de negocio'),
('config', 2, 100, 10, 0, 'default', 1, 'Canal para configuración y datos maestros'),
('files', 3, 10, 5, 0, 'default', 1, 'Canal para sincronización de archivos'),
('heartbeat', 10, 1, 1, 0, 'default', 1, 'Canal para latidos del sistema');

-- Configuración adicional para batch processing
UPDATE sym_channel SET 
    max_data_to_route = 100000,
    use_old_data_to_route = 1,
    use_row_data_to_route = 1,
    use_pk_data_to_route = 1,
    contains_big_lob = 0,
    reload_flag = 0,
    file_sync_flag = 0
WHERE channel_id IN ('dml', 'config');

UPDATE sym_channel SET 
    file_sync_flag = 1,
    reload_flag = 0
WHERE channel_id = 'files';

-- Confirmar inserción
SELECT channel_id, processing_order, max_batch_size, enabled, description 
FROM sym_channel 
ORDER BY processing_order;
