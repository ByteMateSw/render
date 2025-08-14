-- ===============================================================================
-- 03_triggers_from_tables_js.sql - Triggers generados desde tables.js
-- ===============================================================================
-- DESCRIPCIÓN: Triggers bidireccionales para todas las tablas del esquema
-- GENERADO AUTOMÁTICAMENTE: Este archivo fue generado analizando tables.js
-- EJECUCIÓN: Ejecutar CUARTO en el nodo maestro PostgreSQL

-- ===============================================================================
-- TABLAS GLOBALES (sin filtro de branch_id, se sincronizan a todas las sucursales)
-- ===============================================================================

-- TRIGGER: country
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('country_trigger', 'country', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla country');

-- TRIGGER: province
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('province_trigger', 'province', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla province');

-- TRIGGER: city
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('city_trigger', 'city', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla city');

-- TRIGGER: branch
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('branch_trigger', 'branch', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla branch');

-- TRIGGER: role
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('role_trigger', 'role', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla role');

-- TRIGGER: status
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('status_trigger', 'status', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla status');

-- TRIGGER: unit_measure
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('unit_measure_trigger', 'unit_measure', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla unit_measure');

-- TRIGGER: category
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('category_trigger', 'category', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla category');

-- TRIGGER: user
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('user_trigger', 'user', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla user');

-- TRIGGER: employee
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('employee_trigger', 'employee', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla employee');

-- TRIGGER: client
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('client_trigger', 'client', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla client');

-- TRIGGER: provider
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('provider_trigger', 'provider', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla provider');

-- TRIGGER: product
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('product_trigger', 'product', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla product');

-- TRIGGER: product_branch
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('product_branch_trigger', 'product_branch', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla product_branch');

-- TRIGGER: voucher_type
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('voucher_type_trigger', 'voucher_type', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla voucher_type');

-- TRIGGER: purchase
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('purchase_trigger', 'purchase', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla purchase');

-- TRIGGER: sale
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('sale_trigger', 'sale', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla sale');

-- TRIGGER: sale_product
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('sale_product_trigger', 'sale_product', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla sale_product');

-- TRIGGER: purchase_product
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('purchase_product_trigger', 'purchase_product', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla purchase_product');

-- TRIGGER: payment_method
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('payment_method_trigger', 'payment_method', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla payment_method');

-- TRIGGER: sale_payment
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('sale_payment_trigger', 'sale_payment', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla sale_payment');

-- TRIGGER: purchase_payment
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('purchase_payment_trigger', 'purchase_payment', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla purchase_payment');

-- TRIGGER: current_account
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('current_account_trigger', 'current_account', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla current_account');

-- TRIGGER: movement
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('movement_trigger', 'movement', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla movement');

-- TRIGGER: transfer_stock
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('transfer_stock_trigger', 'transfer_stock', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla transfer_stock');

-- TRIGGER: purchase_distribution
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('purchase_distribution_trigger', 'purchase_distribution', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla purchase_distribution');

-- TRIGGER: device_registry
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('device_registry_trigger', 'device_registry', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla device_registry');

-- TRIGGER: current_account_log
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('current_account_log_trigger', 'current_account_log', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla current_account_log');

-- TRIGGER: current_account_payment
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('current_account_payment_trigger', 'current_account_payment', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla current_account_payment');

-- TRIGGER: device_afip_config
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('device_afip_config_trigger', 'device_afip_config', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla device_afip_config');

-- TRIGGER: app_settings
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('app_settings_trigger', 'app_settings', 'dml', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla app_settings');

-- ===============================================================================
-- CONFIRMACIÓN: Verificar triggers creados
-- ===============================================================================
SELECT 
    trigger_id,
    source_table_name,
    channel_id,
    sync_on_insert,
    sync_on_update,
    sync_on_delete,
    description
FROM sym_trigger
WHERE trigger_id LIKE '%_trigger'
ORDER BY source_table_name;
