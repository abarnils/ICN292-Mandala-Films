# CHANGELOG

Cambios relevantes realizados desde la Entrega 1 (E1).

## Entrega 2 (E2)

### BPMN y automatización

**Agregado**
- Documentación de la automatización del control de sobrecostos en `docs/05-automatizacion-n8n.md`.
- Dos workflows en n8n, uno utilizado como emisor de gastos de prueba y otro encargado de evaluar el sobrecosto.
- Casos de prueba S01 a S07 para comprobar las distintas salidas del flujo.
- Registro de resultados en Google Sheets y notificaciones de prueba mediante webhook.site.
- Archivos JSON de los workflows y capturas utilizadas como evidencia.

**Cambiado respecto de E1**
- En la Entrega 1 el BPMN To-Be planteaba la automatización como parte del diseño futuro del SIG, pero todavía no existía un flujo implementado.
- En la Entrega 2 se implementó específicamente el control de sobrecostos asociado al RF04.
- Se mantuvieron manuales la evaluación del sobrecosto y los cambios de etapa del proyecto, respetando la decisión del dueño de no automatizar completamente el avance.
- La automatización implementada en n8n clasifica un gasto como CERCA desde el 80 % y como SUPERADO desde el 100 %.

### Modelo de datos

**Agregado**
- Modelo entidad-relación final normalizado a 3FN.
- Catálogos para etapas, roles, tipos de hito y categorías de gasto.
- Tabla `USUARIO` para cubrir el requisito de autenticación.
- Diccionario de datos y reglas de integridad.
- Vistas y restricciones para evitar duplicidades, inconsistencias y atributos derivados almacenados de forma redundante.

**Cambiado respecto de E1**
- `CLIENTE.contacto` se separó en `email` y `telefono`.
- Se eliminó `PROYECTO.presupuesto_aprobado`, ya que el presupuesto se obtiene desde la cotización aprobada.
- `PROYECTO.estado_actual` pasó a relacionarse mediante una FK con `ETAPA`.
- Los roles dejaron de almacenarse como texto libre y pasaron a un catálogo `ROL`.
- `ASIGNACION_PROYECTO.honorario_calculado` se reemplazó por jornadas y tarifa pactada, dejando el cálculo del honorario en una vista.
- En `HITO`, la etapa y el estado dejaron de almacenarse directamente; se incorporó `TIPO_HITO` y el estado se obtiene a partir de las fechas.
- En `GASTO`, la categoría y el tipo se reorganizaron mediante `CATEGORIA_GASTO`.
- Se eliminó `FACTURA.id_proyecto`, ya que el proyecto se obtiene a través de la orden de compra y la cotización.
- Se eliminó `FACTURA.iva`, ya que se calcula desde el monto neto.
- En `INDICADOR_FINANCIERO` se conservaron los insumos históricos y los valores derivados se calculan mediante una vista.
- Se agregaron atributos de pago y número de factura que no estaban presentes en el modelo preliminar.

### Base de datos y consultas SQL

**Agregado**
- Base de datos de prueba con información de proyectos, trabajadores, honorarios y costos fijos.
- Datos sintéticos para ejecutar pruebas sin utilizar información personal real de la empresa.
- Diez trabajadores ficticios, tres proyectos, doce asignaciones de trabajadores a proyectos y cuatro costos fijos.
- Tres consultas SQL orientadas a revisar el estado económico y los trabajadores asociados a un proyecto, revisar la participación y honorarios de trabajadores durante un período, y obtener un consolidado de ingresos, gastos y resultado de un período.
- Resultados de ejecución de las consultas para comprobar su funcionamiento.

**Cambiado respecto de E1**
- En la Entrega 1 se presentó un modelo de datos preliminar, sin consultas de negocio implementadas.
- En la Entrega 2 se incorporaron datos de prueba y consultas que permiten obtener información concreta para el control de proyectos, honorarios y costos.

### Documentación

**Agregado**
- Actualización de `docs/00-caso-pyme.md`.
- Revisión y actualización de `docs/01-requerimientos.md`.
- Registro de cambios entre E1 y E2 mediante `CHANGELOG.md`.
- Declaración de uso de IA mediante `DECLARACION_IA.md`.
- Trazabilidad entre la Entrega 1 y la Entrega 2.
- Sección de lecciones aprendidas y limitaciones.

**Cambiado respecto de E1**
- La documentación deja de describir únicamente una propuesta preliminar y pasa a incorporar decisiones de diseño finales, pruebas, resultados, errores encontrados y limitaciones observadas durante la implementación.
