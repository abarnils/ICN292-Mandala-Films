# Automatización con n8n

## 1. Qué se automatizó

Se automatizó el control de sobrecosto del BPMN to-be: la tarea “Ingresar gastos variables ejecutados al SIG”, el gateway “¿Gastos ejecutados cerca o superiores al presupuesto?” y la tarea “Enviar alerta de sobrecosto”. Responde a RF04 (alerta cuando el gasto se acerca o supera el presupuesto) y al problema de B3: se pierden montos en gastos como bencina y arriendos.

No se automatizó la tarea “Evaluar sobrecosto y ajustar a presupuesto”, que sigue siendo manual (Administración y Finanzas), ni los cambios de etapa, porque el dueño pidió ingresarlos a mano.

## 2. Cómo está armado

Son dos workflows en n8n:

- Emisor: Trigger manual → Code → HTTP Request. Simula al SIG: genera siete gastos de prueba y los envía de a uno, cada 3 segundos, al webhook (Batching: 1 ítem por lote, 3000 ms).
- Sobrecosto: Webhook → Edit Fields → Switch → cuatro Edit Fields (uno por salida) → HTTP Request (notificación), Registro (Google Sheets) y Respond to Webhook.

Trazabilidad con el BPMN to-be:

| Nodo en n8n | Tarea del BPMN | Qué hace |
|---|---|---|
| Emisor (Trigger manual, Code, HTTP Request) | Ingresar gastos variables ejecutados al SIG | Simula al SIG enviando un gasto. |
| Webhook | Ingresar gastos variables ejecutados al SIG | Recibe el gasto con id_proyecto, categoria, monto, presupuesto_aprobado y gasto_acumulado. |
| Edit Fields (porcentaje_ejecutado) | Gateway ¿Gastos ejecutados cerca o superiores al presupuesto? | Calcula el porcentaje ejecutado. |
| Switch | Mismo gateway | Clasifica en INVALIDO, SUPERADO, CERCA u OK. |
| Cuatro Edit Fields | Salidas del gateway | Fijan estado, fecha y mensaje. |
| HTTP Request (webhook.site) | Enviar alerta de sobrecosto | Notifica solo en CERCA y SUPERADO. |
| Registro (Google Sheets) | Sin tarea propia | Guarda cada decisión como rastro auditable. |
| Respond to Webhook | Sin tarea propia | Responde al emisor. |

## 3. Reglas de clasificación

El primer Edit Fields calcula `porcentaje_ejecutado = (gasto_acumulado + monto) / presupuesto_aprobado × 100`. El Switch evalúa en este orden y cada gasto sale por la primera regla que cumple:

- INVALIDO_PRESUPUESTO: `presupuesto_aprobado` menor o igual a 0.
- INVALIDO_MONTO: `monto` menor o igual a 0.
- SUPERADO: porcentaje mayor o igual a 100.
- CERCA: porcentaje mayor o igual a 80.
- OK: el resto (salida de respaldo).

Las comparaciones son inclusivas: un gasto que llega justo al 80% es CERCA y justo al 100% es SUPERADO. El umbral de 80% fue propuesto por el equipo y validado por el dueño.

Solo CERCA y SUPERADO envían notificación. Todos los estados quedan en el registro.

## 4. Pruebas

Los casos son sintéticos (proyectos PRY-001 y PRY-002, montos de ejemplo). Tanto la falla de S07 como la corrida final de los siete casos se ejecutaron con la Production URL.

| Caso | Entrada | Esperado | Observado |
|---|---|---|---|
| S01 | PRY-001, bencina, monto 50.000, acumulado 300.000, presupuesto 1.000.000 | OK (35%) | OK, 35% |
| S02 | PRY-001, colaciones, monto 100.000, acumulado 700.000, presupuesto 1.000.000 | CERCA (80%) | CERCA, 80% |
| S03 | PRY-001, arriendo, monto 100.000, acumulado 900.000, presupuesto 1.000.000 | SUPERADO (100%) | SUPERADO, 100% |
| S04 | PRY-001, arriendo, monto 150.000, acumulado 950.000, presupuesto 1.000.000 | SUPERADO (110%) | SUPERADO, 110% |
| S05 | PRY-002, bencina, monto 30.000, presupuesto 0 | INVALIDO | INVALIDO; porcentaje vacío |
| S06 | PRY-002, bencina, monto -5.000, acumulado 100.000, presupuesto 800.000 | INVALIDO | INVALIDO; porcentaje 11,875 sin sentido |
| S07 | PRY-001, arriendo, monto 50.000, presupuesto 1.000.000, sin gasto_acumulado | Falla | Falló en Edit Fields (NaN); sin fila ni alerta |

En la hoja registro_sobrecosto quedaron seis filas, una por caso salvo S07, con los estados esperados. En webhook.site llegaron tres notificaciones de la corrida final, con 3 segundos entre cada una: CERCA con 80% (S02), SUPERADO con 100% (S03) y SUPERADO con 110% (S04). Los casos OK e INVALIDO no notificaron, como corresponde.

## 5. Qué falló y cómo se resolvió

- S07 (falta gasto_acumulado): el Edit Fields falló con “'porcentaje_ejecutado' expects a number but we got 'NaN'”. El flujo se corta antes del Switch y no deja fila en el registro ni alerta. Un gasto con datos incompletos se pierde sin rastro.
- Cálculo antes de validar: en S05 (presupuesto 0) la división da infinito y la celda del porcentaje queda vacía; en S06 (monto negativo) queda un porcentaje sin sentido (11,875). El Switch igual los clasifica como INVALIDO, pero el valor guardado no sirve.
- Filas perdidas con envíos simultáneos: en una primera corrida, con los siete casos enviados casi a la vez, solo quedaron 2 filas en la hoja, con la misma hora al segundo. Al enviar de a uno cada 3 segundos quedaron las seis esperadas. La causa más probable son escrituras simultáneas en Google Sheets que se pisan; no se comprobó directamente.

## 6. Limitaciones

- El emisor simula al SIG porque la aplicación no existe todavía. El gasto llega con presupuesto_aprobado y gasto_acumulado ya incluidos; el flujo no los lee de la base de datos.
- La notificación va a webhook.site, no a Administración y Finanzas.
- El registro se hace en una hoja de Google, no en la base de datos del modelo de datos.
- Los datos son sintéticos.
- El flujo calcula el porcentaje antes de validar los datos, y una falla como la de S07 no deja fila en el registro ni alerta.

## 7. Evidencia

Los workflows exportados en JSON y las capturas de las pruebas están en el repositorio.
