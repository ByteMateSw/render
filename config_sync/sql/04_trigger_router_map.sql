-- ===============================================================================
-- 04_trigger_router_map.sql - Mapeo de Triggers a Routers
-- ===============================================================================
-- DESCRIPCIÓN: Mapea todos los triggers bidireccionales a los routers correspondientes
-- EJECUCIÓN: Ejecutar QUINTO en el nodo maestro PostgreSQL

-- ===============================================================================
-- MAPEO BIDIRECCIONAL: Todos los triggers se mapean a ambos routers
-- ===============================================================================

-- Mapeo: Server -> Clients (maestro hacia sucursales)
INSERT INTO sym_trigger_router 
(trigger_id, router_id, initial_load_order, last_update_time, create_time, enabled, description)
VALUES
('country_trigger', 'server_to_clients', 10, current_timestamp, current_timestamp, 1, 'Sincronización country: servidor -> clientes'),
('province_trigger', 'server_to_clients', 20, current_timestamp, current_timestamp, 1, 'Sincronización province: servidor -> clientes'),
('city_trigger', 'server_to_clients', 30, current_timestamp, current_timestamp, 1, 'Sincronización city: servidor -> clientes'),
('branch_trigger', 'server_to_clients', 40, current_timestamp, current_timestamp, 1, 'Sincronización branch: servidor -> clientes'),
('role_trigger', 'server_to_clients', 50, current_timestamp, current_timestamp, 1, 'Sincronización role: servidor -> clientes'),
('status_trigger', 'server_to_clients', 60, current_timestamp, current_timestamp, 1, 'Sincronización status: servidor -> clientes'),
('unit_measure_trigger', 'server_to_clients', 70, current_timestamp, current_timestamp, 1, 'Sincronización unit_measure: servidor -> clientes'),
('category_trigger', 'server_to_clients', 80, current_timestamp, current_timestamp, 1, 'Sincronización category: servidor -> clientes'),
('voucher_type_trigger', 'server_to_clients', 90, current_timestamp, current_timestamp, 1, 'Sincronización voucher_type: servidor -> clientes'),
('payment_method_trigger', 'server_to_clients', 100, current_timestamp, current_timestamp, 1, 'Sincronización payment_method: servidor -> clientes'),
('user_trigger', 'server_to_clients', 110, current_timestamp, current_timestamp, 1, 'Sincronización user: servidor -> clientes'),
('employee_trigger', 'server_to_clients', 120, current_timestamp, current_timestamp, 1, 'Sincronización employee: servidor -> clientes'),
('client_trigger', 'server_to_clients', 130, current_timestamp, current_timestamp, 1, 'Sincronización client: servidor -> clientes'),
('provider_trigger', 'server_to_clients', 140, current_timestamp, current_timestamp, 1, 'Sincronización provider: servidor -> clientes'),
('product_trigger', 'server_to_clients', 150, current_timestamp, current_timestamp, 1, 'Sincronización product: servidor -> clientes'),
('product_branch_trigger', 'server_to_clients', 160, current_timestamp, current_timestamp, 1, 'Sincronización product_branch: servidor -> clientes'),
('device_registry_trigger', 'server_to_clients', 170, current_timestamp, current_timestamp, 1, 'Sincronización device_registry: servidor -> clientes'),
('device_afip_config_trigger', 'server_to_clients', 180, current_timestamp, current_timestamp, 1, 'Sincronización device_afip_config: servidor -> clientes'),
('app_settings_trigger', 'server_to_clients', 190, current_timestamp, current_timestamp, 1, 'Sincronización app_settings: servidor -> clientes'),
('purchase_trigger', 'server_to_clients', 200, current_timestamp, current_timestamp, 1, 'Sincronización purchase: servidor -> clientes'),
('sale_trigger', 'server_to_clients', 210, current_timestamp, current_timestamp, 1, 'Sincronización sale: servidor -> clientes'),
('sale_product_trigger', 'server_to_clients', 220, current_timestamp, current_timestamp, 1, 'Sincronización sale_product: servidor -> clientes'),
('purchase_product_trigger', 'server_to_clients', 230, current_timestamp, current_timestamp, 1, 'Sincronización purchase_product: servidor -> clientes'),
('sale_payment_trigger', 'server_to_clients', 240, current_timestamp, current_timestamp, 1, 'Sincronización sale_payment: servidor -> clientes'),
('purchase_payment_trigger', 'server_to_clients', 250, current_timestamp, current_timestamp, 1, 'Sincronización purchase_payment: servidor -> clientes'),
('current_account_trigger', 'server_to_clients', 260, current_timestamp, current_timestamp, 1, 'Sincronización current_account: servidor -> clientes'),
('current_account_log_trigger', 'server_to_clients', 270, current_timestamp, current_timestamp, 1, 'Sincronización current_account_log: servidor -> clientes'),
('current_account_payment_trigger', 'server_to_clients', 280, current_timestamp, current_timestamp, 1, 'Sincronización current_account_payment: servidor -> clientes'),
('movement_trigger', 'server_to_clients', 290, current_timestamp, current_timestamp, 1, 'Sincronización movement: servidor -> clientes'),
('transfer_stock_trigger', 'server_to_clients', 300, current_timestamp, current_timestamp, 1, 'Sincronización transfer_stock: servidor -> clientes'),
('purchase_distribution_trigger', 'server_to_clients', 310, current_timestamp, current_timestamp, 1, 'Sincronización purchase_distribution: servidor -> clientes');

-- Mapeo: Clients -> Server (sucursales hacia maestro)
INSERT INTO sym_trigger_router 
(trigger_id, router_id, initial_load_order, last_update_time, create_time, enabled, description)
VALUES
('country_trigger', 'clients_to_server', 10, current_timestamp, current_timestamp, 1, 'Sincronización country: clientes -> servidor'),
('province_trigger', 'clients_to_server', 20, current_timestamp, current_timestamp, 1, 'Sincronización province: clientes -> servidor'),
('city_trigger', 'clients_to_server', 30, current_timestamp, current_timestamp, 1, 'Sincronización city: clientes -> servidor'),
('branch_trigger', 'clients_to_server', 40, current_timestamp, current_timestamp, 1, 'Sincronización branch: clientes -> servidor'),
('role_trigger', 'clients_to_server', 50, current_timestamp, current_timestamp, 1, 'Sincronización role: clientes -> servidor'),
('status_trigger', 'clients_to_server', 60, current_timestamp, current_timestamp, 1, 'Sincronización status: clientes -> servidor'),
('unit_measure_trigger', 'clients_to_server', 70, current_timestamp, current_timestamp, 1, 'Sincronización unit_measure: clientes -> servidor'),
('category_trigger', 'clients_to_server', 80, current_timestamp, current_timestamp, 1, 'Sincronización category: clientes -> servidor'),
('voucher_type_trigger', 'clients_to_server', 90, current_timestamp, current_timestamp, 1, 'Sincronización voucher_type: clientes -> servidor'),
('payment_method_trigger', 'clients_to_server', 100, current_timestamp, current_timestamp, 1, 'Sincronización payment_method: clientes -> servidor'),
('user_trigger', 'clients_to_server', 110, current_timestamp, current_timestamp, 1, 'Sincronización user: clientes -> servidor'),
('employee_trigger', 'clients_to_server', 120, current_timestamp, current_timestamp, 1, 'Sincronización employee: clientes -> servidor'),
('client_trigger', 'clients_to_server', 130, current_timestamp, current_timestamp, 1, 'Sincronización client: clientes -> servidor'),
('provider_trigger', 'clients_to_server', 140, current_timestamp, current_timestamp, 1, 'Sincronización provider: clientes -> servidor'),
('product_trigger', 'clients_to_server', 150, current_timestamp, current_timestamp, 1, 'Sincronización product: clientes -> servidor'),
('product_branch_trigger', 'clients_to_server', 160, current_timestamp, current_timestamp, 1, 'Sincronización product_branch: clientes -> servidor'),
('device_registry_trigger', 'clients_to_server', 170, current_timestamp, current_timestamp, 1, 'Sincronización device_registry: clientes -> servidor'),
('device_afip_config_trigger', 'clients_to_server', 180, current_timestamp, current_timestamp, 1, 'Sincronización device_afip_config: clientes -> servidor'),
('app_settings_trigger', 'clients_to_server', 190, current_timestamp, current_timestamp, 1, 'Sincronización app_settings: clientes -> servidor'),
('purchase_trigger', 'clients_to_server', 200, current_timestamp, current_timestamp, 1, 'Sincronización purchase: clientes -> servidor'),
('sale_trigger', 'clients_to_server', 210, current_timestamp, current_timestamp, 1, 'Sincronización sale: clientes -> servidor'),
('sale_product_trigger', 'clients_to_server', 220, current_timestamp, current_timestamp, 1, 'Sincronización sale_product: clientes -> servidor'),
('purchase_product_trigger', 'clients_to_server', 230, current_timestamp, current_timestamp, 1, 'Sincronización purchase_product: clientes -> servidor'),
('sale_payment_trigger', 'clients_to_server', 240, current_timestamp, current_timestamp, 1, 'Sincronización sale_payment: clientes -> servidor'),
('purchase_payment_trigger', 'clients_to_server', 250, current_timestamp, current_timestamp, 1, 'Sincronización purchase_payment: clientes -> servidor'),
('current_account_trigger', 'clients_to_server', 260, current_timestamp, current_timestamp, 1, 'Sincronización current_account: clientes -> servidor'),
('current_account_log_trigger', 'clients_to_server', 270, current_timestamp, current_timestamp, 1, 'Sincronización current_account_log: clientes -> servidor'),
('current_account_payment_trigger', 'clients_to_server', 280, current_timestamp, current_timestamp, 1, 'Sincronización current_account_payment: clientes -> servidor'),
('movement_trigger', 'clients_to_server', 290, current_timestamp, current_timestamp, 1, 'Sincronización movement: clientes -> servidor'),
('transfer_stock_trigger', 'clients_to_server', 300, current_timestamp, current_timestamp, 1, 'Sincronización transfer_stock: clientes -> servidor'),
('purchase_distribution_trigger', 'clients_to_server', 310, current_timestamp, current_timestamp, 1, 'Sincronización purchase_distribution: clientes -> servidor');

-- ===============================================================================
-- CONFIGURACIÓN ADICIONAL: Initial Load Order y opciones avanzadas
-- ===============================================================================

-- Configurar initial load sequences para dependencias correctas
UPDATE sym_trigger_router SET 
    initial_load_order = 1,
    initial_load_batch_count = 1
WHERE trigger_id IN ('country_trigger', 'role_trigger', 'status_trigger', 'unit_measure_trigger', 'category_trigger', 'voucher_type_trigger', 'payment_method_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 2,
    initial_load_batch_count = 1
WHERE trigger_id IN ('province_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 3,
    initial_load_batch_count = 1
WHERE trigger_id IN ('city_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 4,
    initial_load_batch_count = 1
WHERE trigger_id IN ('branch_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 5,
    initial_load_batch_count = 1
WHERE trigger_id IN ('user_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 6,
    initial_load_batch_count = 1
WHERE trigger_id IN ('employee_trigger', 'client_trigger', 'provider_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 7,
    initial_load_batch_count = 1
WHERE trigger_id IN ('product_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 8,
    initial_load_batch_count = 1
WHERE trigger_id IN ('product_branch_trigger', 'device_registry_trigger', 'device_afip_config_trigger', 'app_settings_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 9,
    initial_load_batch_count = 1
WHERE trigger_id IN ('purchase_trigger', 'sale_trigger');

UPDATE sym_trigger_router SET 
    initial_load_order = 10,
    initial_load_batch_count = 1
WHERE trigger_id IN ('sale_product_trigger', 'purchase_product_trigger', 'sale_payment_trigger', 'purchase_payment_trigger', 'current_account_trigger', 'current_account_log_trigger', 'current_account_payment_trigger', 'movement_trigger', 'transfer_stock_trigger', 'purchase_distribution_trigger');

-- ===============================================================================
-- CONFIRMACIÓN: Verificar mapeos creados
-- ===============================================================================
SELECT 
    tr.trigger_id,
    tr.router_id,
    tr.initial_load_order,
    tr.enabled,
    t.source_table_name,
    r.description AS router_description
FROM sym_trigger_router tr
JOIN sym_trigger t ON tr.trigger_id = t.trigger_id
JOIN sym_router r ON tr.router_id = r.router_id
ORDER BY tr.router_id, tr.initial_load_order, tr.trigger_id;
