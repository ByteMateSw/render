-- ===============================================================================
-- 01_node_groups_and_links.sql - Configuración de Grupos de Nodos y Enlaces
-- ===============================================================================
-- DESCRIPCIÓN: Define grupos server/client y sus vínculos bidireccionales
-- EJECUCIÓN: Ejecutar SEGUNDO en el nodo maestro PostgreSQL

-- Crear grupos de nodos
INSERT INTO sym_node_group 
(node_group_id, description, created_at, last_update_time) 
VALUES
('server', 'Nodo maestro PostgreSQL en Render.com', current_timestamp, current_timestamp),
('client', 'Nodos cliente MySQL en sucursales', current_timestamp, current_timestamp);

-- Configurar links bidireccionales entre grupos
-- Server -> Clients (maestro envía a sucursales)
INSERT INTO sym_node_group_link 
(source_node_group_id, target_node_group_id, data_event_action, sync_config_enabled, is_reversible, created_at, last_update_time) 
VALUES
('server', 'client', 'W', 1, 0, current_timestamp, current_timestamp);

-- Clients -> Server (sucursales envían al maestro)
INSERT INTO sym_node_group_link 
(source_node_group_id, target_node_group_id, data_event_action, sync_config_enabled, is_reversible, created_at, last_update_time) 
VALUES
('client', 'server', 'W', 1, 0, current_timestamp, current_timestamp);

-- Configurar canales por defecto para cada link
INSERT INTO sym_node_channel_ctl 
(node_group_id, channel_id, suspend_enabled, ignore_enabled, last_extract_time, created_at, last_update_time)
SELECT ng.node_group_id, c.channel_id, 0, 0, '1970-01-01 00:00:00', current_timestamp, current_timestamp
FROM sym_node_group ng
CROSS JOIN sym_channel c
WHERE ng.node_group_id IN ('server', 'client')
AND c.channel_id IN ('dml', 'config', 'files', 'heartbeat');

-- Confirmar configuración
SELECT 
    ngl.source_node_group_id,
    ngl.target_node_group_id,
    ngl.data_event_action,
    ngl.sync_config_enabled,
    ngl.is_reversible
FROM sym_node_group_link ngl
ORDER BY ngl.source_node_group_id, ngl.target_node_group_id;
