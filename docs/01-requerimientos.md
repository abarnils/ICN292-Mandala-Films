# Requerimientos desde cero

## Actores y roles

**Productor:** gestiona el proyecto de punta a punta, ingresa datos, confirma hitos de avance.

**Director:** supervisa aspectos creativos, aprueba guion y define equipo de grabación.

**Administración y Finanzas:** revisa costos, honorarios, márgenes y KPI; gestiona cierre financiero.

**Equipo de producción** (camarógrafo, editor, guionista, diseñador gráfico, locutor, asistente): ejecuta tareas operativas según la etapa del proyecto.

**Cliente:** solicita cotización, aprueba presupuesto/guion, recibe entregable final.

**Entidad de facturación:** sistema externo ([facturacion.cl](https://facturacion.cl/)) de facturación electrónica.

## Alcance in / out

**Dentro del alcance:**

\-Registro del ciclo de vida del proyecto desde la aceptación de la cotización hasta el cierre.

\-Gestión de etapas: Preproducción, Grabación, Postproducción y Cierre.

\-Cálculo automático de costos, honorarios, IVA, EBITDA y márgenes al aceptar la cotización.

\-Dashboard de KPIs financieros y operacionales por proyecto y consolidado mensual.

\-Registro del capital/presupuesto restante por proyecto.

\-Carta Gantt por proyecto.

**Fuera del alcance:**

\-Emisión de facturas electrónicas (se mantendrá Facturacion.cl como sistema externo).

\-Automatización de avances de etapa sin confirmación manual del usuario.

\-Gestión de personas (contratos, vacaciones, cotizaciones previsionales).

\-CRM avanzado de clientes.

## Requisitos funcionales

|ID|Requisito|Prioridad|Traza a|
|-|-|-|-|
|RF01|El sistema debe permitir registrar los datos del proyecto al aceptarse la cotización, pasando automáticamente al estado "Preproducción".|Must|B3, B4|
|RF02|El sistema debe permitir confirmar hitos de preproducción (visita a locación, confirmación de equipo) para habilitar el paso a "Grabación".|Must|B4|
|RF03|El sistema debe permitir confirmar hitos de postproducción (locución, diseño gráfico, montaje) para pasar el proyecto a "Cierre".|Must|B4|
|RF04|El sistema debe calcular automáticamente honorarios, costos fijos, IVA, EBITDA y márgenes al aceptarse la cotización, en base a los datos del presupuesto inicial. Además, debe permitir agregar o editar manualmente gastos no fijos asociados a cada proyecto, de manera que el sistema notifique al usuario cuando el gasto ejecutado de un proyecto se acerque o supere el presupuesto asignado.|Must|B3, B4|
|RF05|El sistema debe mostrar un dashboard con KPIs financieros y operacionales por proyecto y de forma consolidada por mes.|Must|B4|
|RF06|El sistema debe permitir visualizar en cualquier momento la etapa actual y el estado de avance de cada proyecto.|Must|B3|
|RF07|El sistema debe generar una carta Gantt por proyecto según sus etapas y fechas.|Should|B4|
|RF08|El sistema debe permitir asignar responsables (rol) a cada etapa del proyecto.|Could|B4|

## Requisitos no funcionales

|ID|Requisito|Prioridad|Traza a|
|-|-|-|-|
|RNF01|El sistema debe ser usable por personal sin formación técnica avanzada, ya que actualmente el registro es manual vía Excel, WhatsApp o pizarra.|Must|B3|
|RNF02|El sistema debe restringir el acceso mediante autenticación (usuario y contraseña), de modo que solo el dueño y la administración financiera puedan acceder a la información del sistema.|Should|B3|
|RNF03|Los datos de proyectos y financieros deben respaldarse de forma periódica.|Must|B3|
|RNF04|El sistema debe ser accesible tanto desde dispositivos móviles (celulares o tablet) como desde dispositivos fijos (computadores de escritorio), considerando que gran parte de la coordinación ocurre por medios como WhatsApp o llamadas.|Should|B3|
|RNF05|El sistema debe responder consultas del estado de proyecto y KPIs en un tiempo razonable (idealmente en pocos segundos).|Should|B4|
|RNF06|El sistema debe permitir exportar el dashboard/reportes en formato PDF o Excel.|Could|B4|



