# 04 — Consultas SQL de negocio

Consultas sobre la base de Mandala Films (PostgreSQL 16), construidas sobre `db/schema.sql` y `db/seed.sql`. Los resultados de este documento se obtuvieron ejecutando esos dos archivos sobre una base vacía; cualquiera puede reproducirlos.

## Cómo reproducirlas

```bash
createdb mandala
psql -d mandala -f db/schema.sql     # crea tablas, vistas y triggers (borra y recrea)
psql -d mandala -f db/seed.sql       # carga datos sintéticos
psql -d mandala -f db/consultas.sql  # ejecuta las 5 consultas
```

Los datos son sintéticos (clientes, personas y folios ficticios). Los montos están en pesos chilenos sin decimales. El IVA es 19 %.

Las vistas usadas (`v_presupuesto_proyecto`, `v_factura`, `v_indicador_financiero`, `v_asignacion_honorario`) calculan lo que el modelo 3FN no guarda como dato; ver `docs/03-modelo-datos.md`.

---

## Q1. ¿Qué proyectos están cerca de superar su presupuesto?

**Pregunta de negocio:** el dueño pierde tiempo detectando desbalances; necesita saber de inmediato qué proyecto gastó casi todo su presupuesto (RF04, regla R15: alerta desde el 90 %).

```sql
SELECT nombre_proyecto, presupuesto, gasto_total, porcentaje_gastado,
       CASE WHEN alerta_sobrecosto THEN 'ALERTA' ELSE 'OK' END AS estado
FROM v_presupuesto_proyecto
ORDER BY porcentaje_gastado DESC;
```

**Resultado:**

| nombre_proyecto | presupuesto | gasto_total | porcentaje_gastado | estado |
|---|---:|---:|---:|---|
| Video corporativo Andes Sur | 9.000.000 | 8.150.000 | 90,6 | ALERTA |
| Spot institucional Aromos | 8.500.000 | 2.255.000 | 26,5 | OK |
| Documental Clínica Vista Norte | 15.000.000 | 2.995.000 | 20,0 | OK |
| Cápsulas educativas Mar Abierto | 6.000.000 | 1.050.000 | 17,5 | OK |
| Cobertura aniversario Mar Abierto | 4.200.000 | 650.000 | 15,5 | OK |

**Interpretación:** solo *Video corporativo Andes Sur* supera el umbral del 90 %: gastó 8,15 millones de un presupuesto de 9 millones. El resto está bajo el 27 %. Esta es la alerta que, según el BPMN to-be, debe revisar Finanzas. El presupuesto es el monto de la cotización APROBADA, que existe en un solo lugar del modelo.

---

## Q2. ¿Cuánto falta por cobrar y a quién?

**Pregunta de negocio:** medir la cobranza pendiente por factura (el to-be mide los tiempos de cobranza). Incluye solo facturas con saldo.

```sql
SELECT cl.nombre AS cliente, p.nombre_proyecto, f.numero_factura,
       f.total, f.pagado, f.saldo
FROM v_factura f
JOIN proyecto p  ON p.id_proyecto = f.id_proyecto
JOIN cliente  cl ON cl.id_cliente = p.id_cliente
WHERE f.saldo > 0
ORDER BY f.saldo DESC;
```

**Resultado:**

| cliente | nombre_proyecto | numero_factura | total | pagado | saldo |
|---|---|---|---:|---:|---:|
| Fundación Mar Abierto | Cápsulas educativas Mar Abierto | F-1002 | 7.140.000 | 3.570.000 | 3.570.000 |

**Interpretación:** hay una sola factura con deuda: la F-1002 de Fundación Mar Abierto, de 7,14 millones (neto más IVA), de la que solo se pagó el anticipo (50 %). Quedan 3,57 millones por cobrar. La factura F-1001 (Constructora Los Aromos) no aparece porque se pagó completa en dos cuotas (anticipo y pago final). El proyecto ya está en etapa Cierre, así que el saldo es cobranza pendiente, no avance de obra.

---

## Q3. ¿La ganancia real fue la proyectada?

**Pregunta de negocio:** el dueño dijo que "se termina perdiendo el conocimiento real de las ganancias". Se compara el EBITDA estimado (al aceptar la cotización) con el real (al cierre), para los proyectos cerrados.

```sql
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
```

**Resultado:**

| nombre_proyecto | ebitda_estimado | ebitda_real | desviacion | margen_estimado | margen_real |
|---|---:|---:|---:|---:|---:|
| Cápsulas educativas Mar Abierto | 3.300.000 | 3.340.000 | +40.000 | 55,0 | 55,7 |
| Spot institucional Aromos | 3.700.000 | 3.555.000 | −145.000 | 43,5 | 41,8 |

**Interpretación:** en los dos proyectos cerrados la desviación es pequeña. *Spot Aromos* ganó 145.000 menos de lo proyectado (−1,7 puntos de margen), porque los honorarios reales subieron 190.000 y los costos fijos 50.000, compensado en parte por 95.000 menos de costos variables. *Cápsulas* ganó 40.000 más (+0,7 puntos). Solo aparecen proyectos con indicador REAL, porque el real se crea al cierre (R13). IVA, EBITDA y margen se calculan en la vista y no se almacenan (3FN).

---

## Q4. ¿Cuál es el resultado de cada proyecto a la fecha?

**Pregunta de negocio:** ver el capital restante por proyecto (alcance del SIG): presupuesto menos honorarios asignados menos gastos registrados.

```sql
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
```

**Resultado:**

| nombre_proyecto | presupuesto | honorarios | gasto_total | resultado_a_la_fecha | margen_pct |
|---|---:|---:|---:|---:|---:|
| Video corporativo Andes Sur | 9.000.000 | 3.740.000 | 8.150.000 | −2.890.000 | −32,1 |
| Cobertura aniversario Mar Abierto | 4.200.000 | 640.000 | 650.000 | 2.910.000 | 69,3 |
| Cápsulas educativas Mar Abierto | 6.000.000 | 1.610.000 | 1.050.000 | 3.340.000 | 55,7 |
| Spot institucional Aromos | 8.500.000 | 2.690.000 | 2.255.000 | 3.555.000 | 41,8 |
| Documental Clínica Vista Norte | 15.000.000 | 3.950.000 | 2.995.000 | 8.055.000 | 53,7 |

**Interpretación:** *Video corporativo Andes Sur* ya está en pérdida: honorarios (3,74 millones) más gastos (8,15 millones) superan los 9 millones de presupuesto, es decir −2,89 millones (−32,1 %), pese a que su EBITDA estimado al aceptar la cotización era positivo (1,2 millones, 13,3 %). Para los proyectos cerrados el resultado coincide con el EBITDA REAL de Q3 (3.340.000 y 3.555.000), lo que confirma que los datos son coherentes. Para proyectos abiertos es un resultado parcial: aún no incluye costos futuros.

---

## Q5. ¿Qué hitos están atrasados?

**Pregunta de negocio:** apoyar la Carta Gantt (RF07) y el control de avance (RF02, RF03): hitos con fecha fin vencida y sin cumplir. Se usa una **fecha de corte fija (2026-11-20)** para que el resultado sea reproducible sin depender del día en que se ejecute.

```sql
SELECT p.nombre_proyecto, t.nombre AS hito, h.fecha_fin_programada,
       DATE '2026-11-20' - h.fecha_fin_programada AS dias_atraso
FROM hito h
JOIN proyecto  p ON p.id_proyecto = h.id_proyecto
JOIN tipo_hito t ON t.id_tipo_hito = h.id_tipo_hito
WHERE h.fecha_cumplimiento IS NULL
  AND h.fecha_fin_programada < DATE '2026-11-20'
ORDER BY dias_atraso DESC;
```

**Resultado:**

| nombre_proyecto | hito | fecha_fin_programada | dias_atraso |
|---|---|---|---:|
| Video corporativo Andes Sur | Montaje | 2026-11-10 | 10 |

**Interpretación:** al 20-11-2026 solo hay un hito vencido: el *Montaje* de *Video corporativo Andes Sur*, con 10 días de atraso. Es el mismo proyecto que aparece en alerta de sobrecosto (Q1) y con resultado negativo (Q4): un proyecto con problemas de costo y de plazo a la vez, que la dirección vería de inmediato en el dashboard en lugar de reconstruirlo desde Excel y WhatsApp.

> La vista `v_hito_estado` calcula el mismo concepto con la fecha del día (`CURRENT_DATE`), por lo que sus resultados cambian según cuándo se ejecute.

---

## Síntesis

Las cinco consultas responden preguntas que hoy el dueño resuelve a mano: dónde hay sobrecosto (Q1), cuánto falta por cobrar (Q2), si la ganancia real fue la proyectada (Q3), cómo va cada proyecto (Q4) y qué está atrasado (Q5). En el caso sintético, un solo proyecto (*Video corporativo Andes Sur*) concentra el sobrecosto, la pérdida y el atraso.
