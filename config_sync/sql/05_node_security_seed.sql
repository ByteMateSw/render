
-- ===============================================================================
-- 05_node_security_seed.sql - Configuración de Seguridad y Nodo Maestro
-- ===============================================================================
-- DESCRIPCIÓN: Configura seguridad de nodos y registra el nodo maestro
-- EJECUCIÓN: Ejecutar SEXTO (último) en el nodo maestro PostgreSQL

-- ===============================================================================
-- CREAR NODO MAESTRO
-- ===============================================================================
INSERT INTO sym_node 
(node_id, node_group_id, external_id, sync_enabled, sync_url, schema_version, symmetric_version, database_type, database_version, heartbeat_time, timezone_offset, batch_to_send_count, batch_in_error_count, created_at, deployment_type) 
VALUES
('server-001', 'server', 'server-001', 1, 'https://sync.<TU_DOMINIO>.com/sync/supabase-server', '3.16.5', '3.16.5', 'postgresql', '15.0', current_timestamp, '+00:00', 0, 0, current_timestamp, 'server');

-- ===============================================================================
-- CONFIGURAR SEGURIDAD DEL NODO MAESTRO
-- ===============================================================================
-- Generar password aleatorio para el nodo maestro (cambiar por uno seguro en producción)
INSERT INTO sym_node_security 
(node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at, rev_initial_load_enabled, rev_initial_load_time) 
VALUES
('server-001', 'MASTER_NODE_PASSWORD_2025', 0, current_timestamp, 1, current_timestamp, current_timestamp, 0, null);

-- ===============================================================================
-- CONFIGURAR REGISTRO AUTOMÁTICO PARA CLIENTES
-- ===============================================================================
-- Permitir auto-registro de nodos cliente con validación por grupo
INSERT INTO sym_node_group_link 
(source_node_group_id, target_node_group_id, data_event_action, sync_config_enabled, is_reversible, created_at, last_update_time)
SELECT 'client', 'server', 'P', 1, 0, current_timestamp, current_timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM sym_node_group_link 
    WHERE source_node_group_id = 'client' 
    AND target_node_group_id = 'server' 
    AND data_event_action = 'P'
);

-- ===============================================================================
-- CONFIGURAR PARÁMETROS GLOBALES
-- ===============================================================================
-- Configuración de auto-registro
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'ALL', 'auto.registration', 'true', current_timestamp, current_timestamp),
('ALL', 'ALL', 'registration.url', 'https://sync.<TU_DOMINIO>.com/sync/supabase-server/registration', current_timestamp, current_timestamp),
('ALL', 'server', 'auto.registration', 'false', current_timestamp, current_timestamp),
('ALL', 'client', 'auto.registration', 'true', current_timestamp, current_timestamp);

-- Configuración de seguridad
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'ALL', 'https.allow.self.signed.certs', 'true', current_timestamp, current_timestamp),
('ALL', 'ALL', 'security.verify.hostname', 'false', current_timestamp, current_timestamp),
('ALL', 'ALL', 'https.verified.server.names', 'sync.<TU_DOMINIO>.com', current_timestamp, current_timestamp);

-- Configuración de jobs
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'server', 'start.push.job', 'true', current_timestamp, current_timestamp),
('ALL', 'server', 'start.pull.job', 'true', current_timestamp, current_timestamp),
('ALL', 'server', 'start.route.job', 'true', current_timestamp, current_timestamp),
('ALL', 'client', 'start.push.job', 'true', current_timestamp, current_timestamp),
('ALL', 'client', 'start.pull.job', 'true', current_timestamp, current_timestamp),
('ALL', 'client', 'start.route.job', 'true', current_timestamp, current_timestamp);

-- Configuración de batches
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'server', 'outgoing.batch.max.bytes.to.sync', '1048576', current_timestamp, current_timestamp),
('ALL', 'server', 'incoming.batch.max.bytes.to.sync', '1048576', current_timestamp, current_timestamp),
('ALL', 'client', 'outgoing.batch.max.bytes.to.sync', '524288', current_timestamp, current_timestamp),
('ALL', 'client', 'incoming.batch.max.bytes.to.sync', '524288', current_timestamp, current_timestamp);

-- Configuración de timers
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'server', 'job.push.period.time.ms', '10000', current_timestamp, current_timestamp),
('ALL', 'server', 'job.pull.period.time.ms', '10000', current_timestamp, current_timestamp),
('ALL', 'client', 'job.push.period.time.ms', '5000', current_timestamp, current_timestamp),
('ALL', 'client', 'job.pull.period.time.ms', '5000', current_timestamp, current_timestamp);

-- ===============================================================================
-- CONFIGURAR INITIAL LOAD AUTOMÁTICO
-- ===============================================================================
-- Configurar para que nuevos nodos reciban carga inicial automática
INSERT INTO sym_parameter 
(external_id, node_group_id, param_key, param_value, created_at, last_update_time)
VALUES
('ALL', 'client', 'initial.load.create.first', 'true', current_timestamp, current_timestamp),
('ALL', 'server', 'initial.load.use.extract.job', 'true', current_timestamp, current_timestamp),
('ALL', 'client', 'initial.load.use.extract.job', 'true', current_timestamp, current_timestamp);

-- ===============================================================================
-- CONFIGURAR TEMPLATE PARA NUEVOS NODOS CLIENTE
-- ===============================================================================
-- Template para auto-registro de sucursales
INSERT INTO sym_node_identity 
(node_id) 
VALUES 
('server-001');

-- ===============================================================================
-- SCRIPTS DE VALIDACIÓN
-- ===============================================================================

-- Verificar configuración del nodo maestro
SELECT 
    n.node_id,
    n.node_group_id,
    n.external_id,
    n.sync_enabled,
    n.sync_url,
    ns.registration_enabled,
    ns.initial_load_enabled
FROM sym_node n
JOIN sym_node_security ns ON n.node_id = ns.node_id
WHERE n.node_group_id = 'server';

-- Verificar parámetros configurados
SELECT 
    param_key,
    node_group_id,
    param_value
FROM sym_parameter
WHERE node_group_id IN ('server', 'client', 'ALL')
ORDER BY node_group_id, param_key;

-- Verificar canales y grupos
SELECT 
    ng.node_group_id,
    ng.description,
    (SELECT COUNT(*) FROM sym_node_group_link WHERE source_node_group_id = ng.node_group_id) as outgoing_links,
    (SELECT COUNT(*) FROM sym_node_group_link WHERE target_node_group_id = ng.node_group_id) as incoming_links
FROM sym_node_group ng
ORDER BY ng.node_group_id;
