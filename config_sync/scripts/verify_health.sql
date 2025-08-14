-- ===============================================================================
-- verify_health.sql - Script de verificación de salud del sistema SymmetricDS
-- ===============================================================================
-- DESCRIPCIÓN: Consultas para monitorear estado de sincronización y salud del sistema
-- USO: Ejecutar en el nodo maestro PostgreSQL para verificar estado general
-- ===============================================================================

-- ===============================================================================
-- 1. ESTADO GENERAL DE NODOS
-- ===============================================================================
SELECT 
    '=== ESTADO GENERAL DE NODOS ===' as seccion;

SELECT 
    n.external_id as "Nodo",
    n.node_group_id as "Grupo",
    CASE 
        WHEN n.sync_enabled = 1 THEN '✅ Habilitado'
        ELSE '❌ Deshabilitado'
    END as "Estado Sync",
    CASE 
        WHEN ns.registration_enabled = 1 THEN '✅ Abierto'
        ELSE '❌ Cerrado'
    END as "Registro",
    CASE 
        WHEN ns.initial_load_enabled = 1 THEN '✅ Habilitado'
        ELSE '❌ Deshabilitado'
    END as "Initial Load",
    n.heartbeat_time as "Último Heartbeat",
    CASE 
        WHEN n.heartbeat_time > (current_timestamp - interval '5 minutes') THEN '🟢 Online'
        WHEN n.heartbeat_time > (current_timestamp - interval '30 minutes') THEN '🟡 Reciente'
        ELSE '🔴 Offline'
    END as "Estado Conexión",
    n.created_at as "Creado"
FROM sym_node n
LEFT JOIN sym_node_security ns ON n.node_id = ns.node_id
ORDER BY n.node_group_id, n.external_id;

-- ===============================================================================
-- 2. ESTADÍSTICAS DE BATCHES PENDIENTES
-- ===============================================================================
SELECT 
    '=== BATCHES PENDIENTES POR NODO ===' as seccion;

SELECT 
    ob.node_id as "Nodo",
    ob.channel_id as "Canal",
    ob.status as "Estado",
    COUNT(*) as "Cantidad",
    MIN(ob.create_time) as "Más Antiguo",
    MAX(ob.create_time) as "Más Reciente",
    SUM(ob.data_event_count) as "Total Eventos"
FROM sym_outgoing_batch ob
WHERE ob.status IN ('NE', 'QY', 'SE', 'LD', 'ER')
GROUP BY ob.node_id, ob.channel_id, ob.status
ORDER BY ob.node_id, ob.channel_id, ob.status;

-- Resumen total de batches pendientes
SELECT 
    'RESUMEN TOTAL BATCHES' as "Tipo",
    status as "Estado",
    COUNT(*) as "Cantidad",
    SUM(data_event_count) as "Eventos Totales"
FROM sym_outgoing_batch 
WHERE status IN ('NE', 'QY', 'SE', 'LD', 'ER')
GROUP BY status
ORDER BY status;

-- ===============================================================================
-- 3. ERRORES RECIENTES
-- ===============================================================================
SELECT 
    '=== ERRORES RECIENTES (últimas 24 horas) ===' as seccion;

SELECT 
    ob.node_id as "Nodo",
    ob.channel_id as "Canal",
    ob.batch_id as "Batch ID",
    ob.sql_state as "SQL State",
    ob.sql_code as "SQL Code",
    LEFT(ob.sql_message, 100) as "Error (primeros 100 chars)",
    ob.last_update_time as "Última Actualización"
FROM sym_outgoing_batch ob
WHERE ob.status = 'ER'
AND ob.last_update_time > (current_timestamp - interval '24 hours')
ORDER BY ob.last_update_time DESC
LIMIT 20;

-- ===============================================================================
-- 4. ESTADÍSTICAS DE COMUNICACIÓN
-- ===============================================================================
SELECT 
    '=== ESTADÍSTICAS DE COMUNICACIÓN ===' as seccion;

SELECT 
    nc.node_id as "Nodo",
    nc.communication_type as "Tipo",
    nc.success_count as "Éxitos Recientes",
    nc.total_success_count as "Total Éxitos",
    nc.fail_count as "Fallos Recientes", 
    nc.total_fail_count as "Total Fallos",
    CASE 
        WHEN nc.total_success_count + nc.total_fail_count > 0 THEN
            ROUND((nc.total_success_count::numeric / (nc.total_success_count + nc.total_fail_count) * 100), 2)
        ELSE 0
    END as "% Éxito",
    nc.last_lock_time as "Última Actividad"
FROM sym_node_communication nc
ORDER BY nc.node_id, nc.communication_type;

-- ===============================================================================
-- 5. ESTADO DE CANALES POR NODO
-- ===============================================================================
SELECT 
    '=== ESTADO DE CANALES POR NODO ===' as seccion;

SELECT 
    ncc.node_id as "Nodo",
    ncc.channel_id as "Canal",
    CASE 
        WHEN ncc.suspend_enabled = 1 THEN '⏸️  Suspendido'
        ELSE '▶️  Activo'
    END as "Estado",
    CASE 
        WHEN ncc.ignore_enabled = 1 THEN '🔇 Ignorado'
        ELSE '🔊 Normal'
    END as "Modo",
    ncc.last_extract_time as "Última Extracción"
FROM sym_node_channel_ctl ncc
ORDER BY ncc.node_id, ncc.channel_id;

-- ===============================================================================
-- 6. ACTIVIDAD RECIENTE DE TRIGGERS
-- ===============================================================================
SELECT 
    '=== ACTIVIDAD RECIENTE DE TRIGGERS (últimas 2 horas) ===' as seccion;

SELECT 
    de.source_node_id as "Nodo Origen",
    t.source_table_name as "Tabla",
    de.event_type as "Tipo Evento",
    COUNT(*) as "Cantidad",
    MAX(de.create_time) as "Último Evento"
FROM sym_data_event de
JOIN sym_trigger t ON de.trigger_hist_id = t.trigger_id
WHERE de.create_time > (current_timestamp - interval '2 hours')
GROUP BY de.source_node_id, t.source_table_name, de.event_type
ORDER BY MAX(de.create_time) DESC, COUNT(*) DESC
LIMIT 30;

-- ===============================================================================
-- 7. RENDIMIENTO DE INITIAL LOADS
-- ===============================================================================
SELECT 
    '=== ESTADO DE INITIAL LOADS ===' as seccion;

SELECT 
    trs.target_node_id as "Nodo Destino",
    trs.source_node_id as "Nodo Origen", 
    trs.table_name as "Tabla",
    trs.setup_batch_count as "Batches Setup",
    trs.data_batch_count as "Batches Datos",
    trs.finalize_batch_count as "Batches Finales",
    CASE 
        WHEN trs.completed = 1 THEN '✅ Completado'
        WHEN trs.cancelled = 1 THEN '❌ Cancelado'
        ELSE '⏳ En Progreso'
    END as "Estado",
    trs.start_time as "Inicio",
    trs.end_time as "Fin",
    CASE 
        WHEN trs.end_time IS NOT NULL AND trs.start_time IS NOT NULL THEN
            EXTRACT(epoch FROM (trs.end_time - trs.start_time)) || ' segundos'
        ELSE 'En curso'
    END as "Duración"
FROM sym_table_reload_status trs
WHERE trs.start_time > (current_timestamp - interval '7 days')
ORDER BY trs.start_time DESC;

-- ===============================================================================
-- 8. SALUD GENERAL DEL SISTEMA
-- ===============================================================================
SELECT 
    '=== RESUMEN DE SALUD DEL SISTEMA ===' as seccion;

-- Resumen por tipo de elemento
SELECT 
    'Nodos Totales' as "Métrica",
    COUNT(*)::text as "Valor"
FROM sym_node
UNION ALL
SELECT 
    'Nodos Activos',
    COUNT(*)::text
FROM sym_node 
WHERE sync_enabled = 1
UNION ALL
SELECT 
    'Nodos Online (último 5 min)',
    COUNT(*)::text
FROM sym_node 
WHERE heartbeat_time > (current_timestamp - interval '5 minutes')
UNION ALL
SELECT 
    'Triggers Configurados',
    COUNT(*)::text
FROM sym_trigger
UNION ALL
SELECT 
    'Canales Activos',
    COUNT(*)::text
FROM sym_channel
WHERE enabled = 1
UNION ALL
SELECT 
    'Batches Pendientes',
    COUNT(*)::text
FROM sym_outgoing_batch 
WHERE status IN ('NE', 'QY', 'SE', 'LD')
UNION ALL
SELECT 
    'Batches con Error',
    COUNT(*)::text
FROM sym_outgoing_batch 
WHERE status = 'ER'
UNION ALL
SELECT 
    'Eventos Hoy',
    COUNT(*)::text
FROM sym_data_event 
WHERE create_time > current_date;

-- ===============================================================================
-- 9. ALERTAS Y RECOMENDACIONES
-- ===============================================================================
SELECT 
    '=== ALERTAS Y RECOMENDACIONES ===' as seccion;

-- Alertas automáticas
SELECT 
    '🚨 ALERTA' as "Tipo",
    'Nodos offline por más de 30 minutos' as "Descripción",
    string_agg(external_id, ', ') as "Nodos Afectados"
FROM sym_node 
WHERE heartbeat_time < (current_timestamp - interval '30 minutes')
AND sync_enabled = 1
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    '⚠️  ADVERTENCIA',
    'Batches con errores pendientes',
    COUNT(*)::text || ' batches'
FROM sym_outgoing_batch 
WHERE status = 'ER'
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    '📊 INFO',
    'Batches pendientes normales',
    COUNT(*)::text || ' batches'
FROM sym_outgoing_batch 
WHERE status IN ('NE', 'QY', 'SE', 'LD')
HAVING COUNT(*) > 10;

-- ===============================================================================
-- 10. COMANDOS ÚTILES PARA TROUBLESHOOTING
-- ===============================================================================
SELECT 
    '=== COMANDOS ÚTILES ===' as seccion;

SELECT 
    'Para reiniciar nodo' as "Acción",
    'UPDATE sym_node SET sync_enabled = 0; UPDATE sym_node SET sync_enabled = 1;' as "Comando SQL"
UNION ALL
SELECT 
    'Para limpiar batches con error',
    'DELETE FROM sym_outgoing_batch WHERE status = ''ER'';'
UNION ALL
SELECT 
    'Para forzar heartbeat',
    'UPDATE sym_node SET heartbeat_time = current_timestamp;'
UNION ALL
SELECT 
    'Para recargar triggers',
    'UPDATE sym_trigger SET last_update_time = current_timestamp;';

-- ===============================================================================
-- FIN DEL REPORTE
-- ===============================================================================
SELECT 
    '=== REPORTE COMPLETADO ===' as seccion,
    current_timestamp as "Generado en";
