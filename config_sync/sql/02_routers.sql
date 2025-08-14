-- ===============================================================================
-- 02_routers.sql - Configuración de Routers de Sincronización
-- ===============================================================================
-- DESCRIPCIÓN: Define routers bidireccionales para enrutamiento de datos
-- EJECUCIÓN: Ejecutar TERCERO en el nodo maestro PostgreSQL

-- Router: Server -> Clients (maestro hacia todas las sucursales)
INSERT INTO sym_router 
(router_id, source_node_group_id, target_node_group_id, router_type, router_expression, sync_on_update, sync_on_insert, sync_on_delete, use_source_catalog_schema, created_at, last_update_time, description) 
VALUES
('server_to_clients', 'server', 'client', 'default', null, 1, 1, 1, 0, current_timestamp, current_timestamp, 'Enrutamiento desde servidor maestro hacia todas las sucursales');

-- Router: Clients -> Server (sucursales hacia maestro)
INSERT INTO sym_router 
(router_id, source_node_group_id, target_node_group_id, router_type, router_expression, sync_on_update, sync_on_insert, sync_on_delete, use_source_catalog_schema, created_at, last_update_time, description) 
VALUES
('clients_to_server', 'client', 'server', 'default', null, 1, 1, 1, 0, current_timestamp, current_timestamp, 'Enrutamiento desde sucursales hacia servidor maestro');

-- Router especializado para datos específicos de sucursal (filtro por branch_id)
INSERT INTO sym_router 
(router_id, source_node_group_id, target_node_group_id, router_type, router_expression, sync_on_update, sync_on_insert, sync_on_delete, use_source_catalog_schema, created_at, last_update_time, description) 
VALUES
('branch_specific', 'server', 'client', 'bsh', 
'if (EXTERNAL_ID.equals(targetNode.getExternalId().replace("sucursal-", ""))) {
    return targetNode.getNodeId();
} else {
    return null;
}', 1, 1, 1, 0, current_timestamp, current_timestamp, 'Router específico para datos de sucursal basado en branch_id');

-- Router para datos globales (sin filtro de sucursal)
INSERT INTO sym_router 
(router_id, source_node_group_id, target_node_group_id, router_type, router_expression, sync_on_update, sync_on_insert, sync_on_delete, use_source_catalog_schema, created_at, last_update_time, description) 
VALUES
('global_data', 'server', 'client', 'default', null, 1, 1, 1, 0, current_timestamp, current_timestamp, 'Router para datos globales que van a todas las sucursales');

-- Confirmar routers creados
SELECT 
    router_id,
    source_node_group_id,
    target_node_group_id,
    router_type,
    sync_on_insert,
    sync_on_update,
    sync_on_delete,
    description
FROM sym_router
ORDER BY router_id;
