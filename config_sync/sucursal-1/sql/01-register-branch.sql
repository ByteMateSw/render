-- ================================================================
-- SCRIPT DE CONFIGURACIÓN - SUCURSAL 001
-- ================================================================
-- PASO 1: Ejecutar en el servidor maestro (Supabase PostgreSQL)
-- Permite el registro de la nueva sucursal
-- ================================================================

-- Registrar la nueva sucursal en el servidor maestro
INSERT INTO sym_node_security 
(node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at_node_id)
VALUES 
('sucursal-001', 'sucursal-password-2024', 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 'supabase-001');

-- Verificar que se registró correctamente
SELECT 
    node_id, 
    registration_enabled, 
    initial_load_enabled, 
    registration_time,
    created_at_node_id
FROM sym_node_security 
WHERE node_id = 'sucursal-001';

-- ================================================================
-- IMPORTANTE: 
-- Este script se ejecuta UNA SOLA VEZ en Supabase PostgreSQL
-- antes de iniciar SymmetricDS en la sucursal
-- ================================================================
