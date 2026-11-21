-- consultas.sql - Consultas de negocio (ver interpretacion en docs/04-sql-consultas.md)

-- Q1. Proyectos cerca de superar su presupuesto
SELECT nombre_proyecto, presupuesto, gasto_total, porcentaje_gastado,
       CASE WHEN alerta_sobrecosto THEN 'ALERTA' ELSE 'OK' END AS estado
FROM v_presupuesto_proyecto
ORDER BY porcentaje_gastado DESC;

-- Q2. Cobranza pendiente por factura
SELECT cl.nombre AS cliente, p.nombre_proyecto, f.numero_factura,
       f.total, f.pagado, f.saldo
FROM v_factura f
JOIN proyecto p  ON p.id_proyecto = f.id_proyecto
JOIN cliente  cl ON cl.id_cliente = p.id_cliente
WHERE f.saldo > 0
ORDER BY f.saldo DESC;

-- Q3. EBITDA estimado vs real en proyectos cerrados
SELECT p.nombre_proyecto,
       e.ebitda AS ebitda_estimado,
       r.ebitda AS ebitda_real,
       r.ebitda - e.ebitda AS desviacion,
       e.margen_pct AS margen_estimado,
       r.margen_pct AS margen_real
FROM proyecto p
JOIN v_indicador_financiero e ON e.id_proyecto = p.id_proyecto AND e.tipo_calculo = 'ESTIMADO'
JOIN v_indicador_financiero r ON r.id_proyecto = p.id_proyecto AND r.tipo_calculo = 'REAL'
ORDER BY p.nombre_proyecto;

-- Q4. Resultado a la fecha por proyecto
SELECT pr.nombre_proyecto,
       pr.presupuesto,
       COALESCE(h.honorarios, 0) AS honorarios,
       pr.gasto_total,
       pr.presupuesto - COALESCE(h.honorarios, 0) - pr.gasto_total AS resultado_a_la_fecha,
       ROUND((pr.presupuesto - COALESCE(h.honorarios, 0) - pr.gasto_total) * 100.0
             / pr.presupuesto, 1) AS margen_pct
FROM v_presupuesto_proyecto pr
LEFT JOIN (SELECT id_proyecto, SUM(honorario) AS honorarios
           FROM v_asignacion_honorario
           GROUP BY id_proyecto) h ON h.id_proyecto = pr.id_proyecto
ORDER BY resultado_a_la_fecha;

-- Q5. Hitos atrasados a fecha de corte 2026-11-20
SELECT p.nombre_proyecto, t.nombre AS hito, h.fecha_fin_programada,
       DATE '2026-11-20' - h.fecha_fin_programada AS dias_atraso
FROM hito h
JOIN proyecto  p ON p.id_proyecto = h.id_proyecto
JOIN tipo_hito t ON t.id_tipo_hito = h.id_tipo_hito
WHERE h.fecha_cumplimiento IS NULL
  AND h.fecha_fin_programada < DATE '2026-11-20'
ORDER BY dias_atraso DESC;
