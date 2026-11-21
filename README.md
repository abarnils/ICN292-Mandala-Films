# SIG Mandala Films

Sistema de Información para la Gestión de proyectos audiovisuales desarrollado para **Productora Audiovisual Mandala Films Ltda.** en el marco de la asignatura **ICN292 — Sistemas de Información para la Gestión**, Universidad Técnica Federico Santa María, Campus Vitacura.

## Descripción del proyecto

Mandala Films realiza actualmente el seguimiento de sus proyectos mediante herramientas separadas como planillas de Excel, calendario, correo, WhatsApp, recordatorios y pizarras. Esto dificulta mantener una visión ordenada del estado de cada proyecto y de sus costos asociados.

El SIG propuesto busca centralizar esa información y permitir el seguimiento de cada proyecto desde la cotización hasta el cierre, incorporando etapas, hitos, gastos, honorarios, facturación, pagos e indicadores financieros.

La solución desarrollada en la Entrega 2 incluye:

* Modelo entidad-relación normalizado a 3FN.
* Base de datos relacional en PostgreSQL 16.
* Reglas de integridad, claves foráneas, restricciones, triggers y vistas.
* Consultas SQL orientadas a información de gestión.
* Automatización en n8n para el control de sobrecostos.
* Documentación de requerimientos, BPMN, modelo de datos, trazabilidad y uso de IA.

## Estructura del repositorio

```text
README.md
CHANGELOG.md
DECLARACION\\\\\\\_IA.md

assets
  n8n/
  consultas.sql
  ...
```

docs/
  00-caso-pyme.md
  01-requerimientos.md
  02-bpmn.md
  03-modelo-datos.md
  04-sql-consultas.md
  05-automatizacion-n8n.md
  Presentación-Proyecto-...pdf

db/
  schema.sql
  seed.sql

informe/
  ...
  ICN292_P100_E2_Barnils_Daroch_Jofre_Pizarro_Dagnino.pdf
  latex/
```

## Requisitos previos

Para ejecutar la base de datos se requiere:

* PostgreSQL 16.
* Una herramienta para ejecutar scripts SQL, por ejemplo pgAdmin o `psql`.

Para revisar o ejecutar la automatización se requiere:

* n8n.
* Los workflows exportados en formato JSON incluidos en el repositorio.

## Cómo levantar la base de datos

### 1\. Crear una base de datos vacía

Crear una base de datos en PostgreSQL para el proyecto. Por ejemplo:

```sql
CREATE DATABASE mandalafilms;
```

Luego conectarse a esa base antes de ejecutar los scripts.

### 2\. Ejecutar `schema.sql`

Ejecutar el archivo:

```text
db/schema.sql
```

Este script crea la estructura principal del sistema, incluyendo las tablas, relaciones, restricciones, triggers y vistas utilizadas por el modelo de datos.

El esquema contempla entidades relacionadas con clientes, proyectos, cotizaciones, órdenes de compra, empleados, asignaciones, hitos, gastos, documentos, facturas, pagos, indicadores financieros y usuarios.

También incorpora vistas para facilitar cálculos y consultas, entre ellas:

* `v\\\\\\\_presupuesto\\\\\\\_proyecto`
* `v\\\\\\\_asignacion\\\\\\\_honorario`
* `v\\\\\\\_hito\\\\\\\_estado`
* `v\\\\\\\_factura`
* `v\\\\\\\_indicador\\\\\\\_financiero`

### 3\. Ejecutar `seed.sql`

Después de crear la estructura, ejecutar:

```text
db/seed.sql
```

Este archivo carga los datos de prueba utilizados para revisar el funcionamiento de la base y realizar consultas sin utilizar información privada real de la empresa.

### 4\. Ejecutar las consultas de negocio

Las consultas desarrolladas para la Entrega 2 se encuentran documentadas en:

```text
docs/04-sql-consultas.md
```

Estas consultas permiten revisar, entre otros aspectos:

* Estado económico de un proyecto.
* Trabajadores asociados a proyectos y sus honorarios.
* Participación de trabajadores durante un período.
* Consolidado de ingresos, costos y resultado de un período.

## Modelo de datos

El modelo final fue normalizado a tercera forma normal (3FN) con el objetivo de reducir redundancias y evitar inconsistencias.

Entre los principales ajustes respecto de la Entrega 1 se encuentran:

* Separación de los datos de contacto del cliente.
* Uso de una tabla de etapas para representar el estado actual del proyecto.
* Creación de catálogos para roles, tipos de hito y categorías de gasto.
* Cálculo de valores derivados mediante vistas.
* Incorporación de reglas de integridad para órdenes de compra, facturas, documentos y pagos.
* Incorporación de una tabla de usuarios para el control de acceso.

El detalle del modelo, diccionario de datos y reglas de integridad se encuentra en:

```text
docs/03-modelo-datos.md
```

## Automatización con n8n

Se implementó un flujo de automatización para el control de sobrecostos asociado al RF04.

El flujo recibe la información de un gasto, calcula el porcentaje ejecutado respecto del presupuesto y clasifica el resultado para determinar si corresponde generar una alerta.

La automatización mantiene manuales aquellas decisiones que requieren revisión humana, como la evaluación del sobrecosto y los cambios de etapa del proyecto.

La documentación completa, pruebas y limitaciones se encuentran en:

```text
docs/05-automatizacion-n8n.md
```

## Documentación adicional

La documentación del proyecto se encuentra organizada en la carpeta `docs/`:

* `00-caso-pyme.md`: descripción de Mandala Films, problema de negocio y objetivo del SIG.
* `01-requerimientos.md`: actores, alcance y requerimientos funcionales y no funcionales.
* `02-bpmn.md`: procesos As-Is y To-Be.
* `03-modelo-datos.md`: modelo ER final, normalización, diccionario de datos y reglas de integridad.
* `04-sql-consultas.md`: consultas SQL y resultados.
* `05-automatizacion-n8n.md`: diseño, pruebas y resultados de la automatización.

## Trazabilidad entre E1 y E2

La Entrega 1 definió el problema de negocio, requerimientos, BPMN, modelo de datos preliminar y arquitectura propuesta.

En la Entrega 2 se avanzó hacia una solución más concreta mediante:

* Normalización y desarrollo del modelo de datos final.
* Implementación de la estructura de base de datos.
* Incorporación de datos de prueba.
* Desarrollo de consultas de negocio.
* Implementación y prueba de la automatización de sobrecostos.
* Actualización de la documentación y registro de cambios.

Los cambios principales se encuentran resumidos en `CHANGELOG.md`.

## Uso de inteligencia artificial

El uso de herramientas de inteligencia artificial durante el desarrollo del proyecto se encuentra declarado en:

```text
DECLARACION\\\\\\\_IA.md
```

## Equipo

* Agustín Barnils
* Paula Daroch
* Catalina Jofre
* Antar Pizarro
* Antonella Dagnino


