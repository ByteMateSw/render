#!/usr/bin/env node

/**
 * ===============================================================================
 * generate_trigger_sql_from_tables_js.js
 * ===============================================================================
 * DESCRIPCIÓN: Script Node.js que lee tables.js y genera automáticamente 
 *              los archivos 03_triggers_from_tables_js.sql y 04_trigger_router_map.sql
 * 
 * USO: node scripts/generate_trigger_sql_from_tables_js.js
 * 
 * PREREQUISITOS: Node.js 14+ instalado
 * ===============================================================================
 */

const fs = require('fs');
const path = require('path');

// Configuración
const TABLES_JS_PATH = '../tables.js';
const OUTPUT_TRIGGERS_PATH = '../sql/03_triggers_from_tables_js.sql';
const OUTPUT_ROUTER_MAP_PATH = '../sql/04_trigger_router_map.sql';

// Tablas que NO deben sincronizarse (localOnly)
const LOCAL_ONLY_TABLES = [
    // Agregar aquí tablas que solo deben existir localmente
    // Ejemplo: 'local_cache', 'temp_data'
];

/**
 * Extrae información de tablas desde tables.js
 */
function extractTablesFromJS(filePath) {
    console.log('📖 Leyendo tables.js...');
    
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Extraer nombres de tablas desde CREATE TABLE statements
        const createTableRegex = /CREATE TABLE IF NOT EXISTS\s+(\w+)\s*\(/gi;
        const tables = [];
        let match;
        
        while ((match = createTableRegex.exec(content)) !== null) {
            const tableName = match[1];
            
            // Saltar tablas localOnly
            if (!LOCAL_ONLY_TABLES.includes(tableName)) {
                tables.push({
                    name: tableName,
                    primaryKey: extractPrimaryKey(content, tableName),
                    hasLocalFilter: hasLocalBranchFilter(content, tableName)
                });
            }
        }
        
        console.log(`✅ Encontradas ${tables.length} tablas para sincronizar`);
        return tables;
        
    } catch (error) {
        console.error('❌ Error leyendo tables.js:', error.message);
        process.exit(1);
    }
}

/**
 * Extrae la clave primaria de una tabla
 */
function extractPrimaryKey(content, tableName) {
    const tableStartRegex = new RegExp(`CREATE TABLE IF NOT EXISTS\\s+${tableName}\\s*\\(`, 'i');
    const startMatch = tableStartRegex.exec(content);
    
    if (!startMatch) return 'id'; // Default
    
    let bracketCount = 1;
    let pos = startMatch.index + startMatch[0].length;
    let tableDefinition = '';
    
    // Extraer definición completa de la tabla
    while (bracketCount > 0 && pos < content.length) {
        const char = content[pos];
        if (char === '(') bracketCount++;
        if (char === ')') bracketCount--;
        if (bracketCount > 0) tableDefinition += char;
        pos++;
    }
    
    // Buscar PRIMARY KEY
    const pkRegex = /(\w+)\s+[^,]*PRIMARY KEY/i;
    const pkMatch = pkRegex.exec(tableDefinition);
    
    return pkMatch ? pkMatch[1] : 'id';
}

/**
 * Verifica si una tabla tiene filtro local (branch_id)
 */
function hasLocalBranchFilter(content, tableName) {
    const tableStartRegex = new RegExp(`CREATE TABLE IF NOT EXISTS\\s+${tableName}\\s*\\(`, 'i');
    const startMatch = tableStartRegex.exec(content);
    
    if (!startMatch) return false;
    
    let bracketCount = 1;
    let pos = startMatch.index + startMatch[0].length;
    let tableDefinition = '';
    
    while (bracketCount > 0 && pos < content.length) {
        const char = content[pos];
        if (char === '(') bracketCount++;
        if (char === ')') bracketCount--;
        if (bracketCount > 0) tableDefinition += char;
        pos++;
    }
    
    return tableDefinition.includes('branch_id');
}

/**
 * Genera el archivo de triggers SQL
 */
function generateTriggersSQL(tables) {
    console.log('🔧 Generando triggers SQL...');
    
    let sql = `-- ===============================================================================
-- 03_triggers_from_tables_js.sql - Triggers generados desde tables.js
-- ===============================================================================
-- DESCRIPCIÓN: Triggers bidireccionales para todas las tablas del esquema
-- GENERADO AUTOMÁTICAMENTE: ${new Date().toISOString()}
-- EJECUCIÓN: Ejecutar CUARTO en el nodo maestro PostgreSQL

-- ===============================================================================
-- TABLAS CONFIGURADAS PARA SINCRONIZACIÓN BIDIRECCIONAL
-- ===============================================================================

`;

    tables.forEach(table => {
        const channelId = table.hasLocalFilter ? 'dml' : 'dml';
        
        sql += `-- TRIGGER: ${table.name}
INSERT INTO sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time, create_time, sync_on_update, sync_on_insert, sync_on_delete, sync_on_incoming_batch, name_for_update_trigger, name_for_insert_trigger, name_for_delete_trigger, excluded_column_names, included_column_names, sync_key_names, tx_id_expression, channel_expression, external_select, use_stream_lobs, use_capture_lobs, use_capture_old_data, use_handle_key_updates, stream_row, description) 
VALUES
('${table.name}_trigger', '${table.name}', '${channelId}', current_timestamp, current_timestamp, 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, 0, 0, 1, 1, 0, 'Trigger bidireccional para tabla ${table.name}');

`;
    });

    sql += `-- ===============================================================================
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
ORDER BY source_table_name;`;

    return sql;
}

/**
 * Genera el archivo de mapeo trigger-router SQL
 */
function generateRouterMapSQL(tables) {
    console.log('🔗 Generando mapeo trigger-router SQL...');
    
    let sql = `-- ===============================================================================
-- 04_trigger_router_map.sql - Mapeo de Triggers a Routers
-- ===============================================================================
-- DESCRIPCIÓN: Mapea todos los triggers bidireccionales a los routers correspondientes
-- GENERADO AUTOMÁTICAMENTE: ${new Date().toISOString()}
-- EJECUCIÓN: Ejecutar QUINTO en el nodo maestro PostgreSQL

-- ===============================================================================
-- MAPEO BIDIRECCIONAL: Todos los triggers se mapean a ambos routers
-- ===============================================================================

-- Mapeo: Server -> Clients (maestro hacia sucursales)
INSERT INTO sym_trigger_router 
(trigger_id, router_id, initial_load_order, last_update_time, create_time, enabled, description)
VALUES
`;

    // Mapeo Server -> Clients
    tables.forEach((table, index) => {
        const order = (index + 1) * 10;
        sql += `('${table.name}_trigger', 'server_to_clients', ${order}, current_timestamp, current_timestamp, 1, 'Sincronización ${table.name}: servidor -> clientes')`;
        sql += index < tables.length - 1 ? ',\n' : ';\n\n';
    });

    sql += `-- Mapeo: Clients -> Server (sucursales hacia maestro)
INSERT INTO sym_trigger_router 
(trigger_id, router_id, initial_load_order, last_update_time, create_time, enabled, description)
VALUES
`;

    // Mapeo Clients -> Server
    tables.forEach((table, index) => {
        const order = (index + 1) * 10;
        sql += `('${table.name}_trigger', 'clients_to_server', ${order}, current_timestamp, current_timestamp, 1, 'Sincronización ${table.name}: clientes -> servidor')`;
        sql += index < tables.length - 1 ? ',\n' : ';\n\n';
    });

    // Configuración de orden de carga inicial
    sql += `-- ===============================================================================
-- CONFIGURACIÓN: Initial Load Order por dependencias
-- ===============================================================================

-- Tablas maestras (orden 1)
UPDATE sym_trigger_router SET 
    initial_load_order = 1,
    initial_load_batch_count = 1
WHERE trigger_id IN ('country_trigger', 'role_trigger', 'status_trigger', 'unit_measure_trigger', 'category_trigger', 'voucher_type_trigger', 'payment_method_trigger');

-- Dependencias nivel 2
UPDATE sym_trigger_router SET 
    initial_load_order = 2,
    initial_load_batch_count = 1
WHERE trigger_id IN ('province_trigger');

-- Dependencias nivel 3
UPDATE sym_trigger_router SET 
    initial_load_order = 3,
    initial_load_batch_count = 1
WHERE trigger_id IN ('city_trigger');

-- Dependencias nivel 4
UPDATE sym_trigger_router SET 
    initial_load_order = 4,
    initial_load_batch_count = 1
WHERE trigger_id IN ('branch_trigger');

-- Dependencias nivel 5
UPDATE sym_trigger_router SET 
    initial_load_order = 5,
    initial_load_batch_count = 1
WHERE trigger_id IN ('user_trigger');

-- Dependencias nivel 6
UPDATE sym_trigger_router SET 
    initial_load_order = 6,
    initial_load_batch_count = 1
WHERE trigger_id IN ('employee_trigger', 'client_trigger', 'provider_trigger');

-- Dependencias nivel 7
UPDATE sym_trigger_router SET 
    initial_load_order = 7,
    initial_load_batch_count = 1
WHERE trigger_id IN ('product_trigger');

-- Dependencias nivel 8
UPDATE sym_trigger_router SET 
    initial_load_order = 8,
    initial_load_batch_count = 1
WHERE trigger_id NOT IN (
    'country_trigger', 'role_trigger', 'status_trigger', 'unit_measure_trigger', 
    'category_trigger', 'voucher_type_trigger', 'payment_method_trigger',
    'province_trigger', 'city_trigger', 'branch_trigger', 'user_trigger',
    'employee_trigger', 'client_trigger', 'provider_trigger', 'product_trigger'
);

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
ORDER BY tr.router_id, tr.initial_load_order, tr.trigger_id;`;

    return sql;
}

/**
 * Función principal
 */
function main() {
    console.log('🚀 Iniciando generación automática de triggers y mapeos...');
    
    // Verificar que existe tables.js
    if (!fs.existsSync(TABLES_JS_PATH)) {
        console.error('❌ No se encontró tables.js en:', path.resolve(TABLES_JS_PATH));
        process.exit(1);
    }
    
    // Extraer tablas
    const tables = extractTablesFromJS(TABLES_JS_PATH);
    
    if (tables.length === 0) {
        console.error('❌ No se encontraron tablas para procesar');
        process.exit(1);
    }
    
    // Mostrar resumen
    console.log('\\n📋 Resumen de tablas:');
    tables.forEach(table => {
        console.log(`  - ${table.name} (PK: ${table.primaryKey}, Filtro local: ${table.hasLocalFilter ? 'Sí' : 'No'})`);
    });
    
    // Generar SQLs
    const triggersSQL = generateTriggersSQL(tables);
    const routerMapSQL = generateRouterMapSQL(tables);
    
    // Crear directorios si no existen
    const sqlDir = path.dirname(OUTPUT_TRIGGERS_PATH);
    if (!fs.existsSync(sqlDir)) {
        fs.mkdirSync(sqlDir, { recursive: true });
    }
    
    // Escribir archivos
    fs.writeFileSync(OUTPUT_TRIGGERS_PATH, triggersSQL);
    fs.writeFileSync(OUTPUT_ROUTER_MAP_PATH, routerMapSQL);
    
    console.log('\\n✅ Archivos generados exitosamente:');
    console.log(`  - ${OUTPUT_TRIGGERS_PATH}`);
    console.log(`  - ${OUTPUT_ROUTER_MAP_PATH}`);
    console.log('\\n🎉 ¡Generación completada!');
}

// Ejecutar si es llamado directamente
if (require.main === module) {
    main();
}

module.exports = { extractTablesFromJS, generateTriggersSQL, generateRouterMapSQL };
