# Requerimientos desde cero

## Actores y roles

**Productor:** gestiona el proyecto de punta a punta, ingresa datos y confirma manualmente los hitos y avances de etapa.

**Director:** supervisa aspectos creativos, aprueba guion y define equipo de grabación.

**Administración y Finanzas:** revisa costos, honorarios, márgenes y KPI; gestiona el cierre financiero y evalúa manualmente los casos de sobrecosto.

**Equipo de producción** (camarógrafo, editor, guionista, diseñador gráfico, locutor, asistente): ejecuta tareas operativas según la etapa del proyecto.

**Cliente:** solicita cotización, aprueba presupuesto/guion y recibe el entregable final.

**Entidad de facturación:** sistema externo ([facturacion.cl](https://facturacion.cl/)) utilizado para la emisión de facturas electrónicas.

## Alcance in / out

**Dentro del alcance:**

- Registro del ciclo de vida del proyecto desde la aceptación de la cotización hasta el cierre.
- Gestión de etapas: Preproducción, Grabación, Postproducción y Cierre.
- Confirmación manual de hitos y avances de etapa por parte del productor.
- Cálculo automático de costos, honorarios, IVA, EBITDA y márgenes al aceptar la cotización.
- Registro de gastos variables y control de sobrecostos.
- Generación de alertas cuando el gasto ejecutado alcanza el 80 % del presupuesto y cuando lo supera.
- Dashboard de KPIs financieros y operacionales por proyecto y consolidado mensual.
- Registro del capital/presupuesto restante por proyecto.
- Carta Gantt por proyecto.

**Fuera del alcance:**

- Emisión de facturas electrónicas, que se mantiene en Facturacion.cl como sistema externo.
- Automatización de los cambios de etapa sin confirmación manual del usuario.
- Decisión automática sobre cómo resolver o ajustar un sobrecosto.
- Gestión de personas (contratos, vacaciones, cotizaciones previsionales).
- CRM avanzado de clientes.

## Requisitos funcionales

| ID | Requisito | Prioridad | Traza a |
|---|---|---|---|
| RF01 | El sistema debe permitir registrar los datos del proyecto al aceptarse la cotización, pasando al estado "Preproducción". | Must | B3, B4 |
| RF02 | El sistema debe permitir confirmar manualmente los hitos de preproducción (visita a locación, confirmación de equipo) para habilitar el paso a "Grabación". | Must | B4 |
| RF03 | El sistema debe permitir confirmar manualmente los hitos de postproducción (locución, diseño gráfico, montaje) para pasar el proyecto a "Cierre". | Must | B4 |
| RF04 | El sistema debe calcular automáticamente honorarios, costos fijos, IVA, EBITDA y márgenes a partir de los datos del proyecto. Además, debe permitir registrar o editar gastos no fijos asociados a cada proyecto y controlar su ejecución respecto del presupuesto. El sistema debe clasificar como **CERCA** los casos desde el 80 % del presupuesto y como **SUPERADO** los casos desde el 100 %, generando notificaciones en ambos estados. La evaluación y decisión posterior ante un sobrecosto se mantiene como una acción manual de Administración y Finanzas. | Must | B3, B4 |
| RF05 | El sistema debe mostrar un dashboard con KPIs financieros y operacionales por proyecto y de forma consolidada por mes. | Must | B4 |
| RF06 | El sistema debe permitir visualizar en cualquier momento la etapa actual y el estado de avance de cada proyecto. | Must | B3 |
| RF07 | El sistema debe generar una carta Gantt por proyecto según sus etapas y fechas. | Should | B4 |
| RF08 | El sistema debe permitir asignar responsables (rol) a cada etapa del proyecto. | Could | B4 |

## Requisitos no funcionales

| ID | Requisito | Prioridad | Traza a |
|---|---|---|---|
| RNF01 | El sistema debe ser usable por personal sin formación técnica avanzada, ya que actualmente el registro se realiza mediante herramientas como Excel, WhatsApp y pizarra. | Must | B3 |
| RNF02 | El sistema debe restringir el acceso mediante autenticación (usuario y contraseña), de modo que solo el dueño y Administración y Finanzas puedan acceder a la información del sistema. | Should | B3 |
| RNF03 | Los datos de proyectos y financieros deben respaldarse de forma periódica. | Must | B3 |
| RNF04 | El sistema debe ser accesible tanto desde dispositivos móviles (celulares o tablet) como desde dispositivos fijos (computadores de escritorio), considerando que gran parte de la coordinación ocurre mediante WhatsApp o llamadas. | Should | B3 |
| RNF05 | El sistema debe responder consultas del estado de proyecto y KPIs en un tiempo razonable, idealmente en pocos segundos. | Should | B4 |
| RNF06 | El sistema debe permitir exportar el dashboard o reportes en formato PDF o Excel. | Could | B4 |

## Ajustes

Respecto de la Entrega 1, se mantuvieron los requerimientos principales y se precisaron algunas reglas a partir de la implementación y las pruebas realizadas. En particular, se confirmó que los cambios de etapa continúan requiriendo confirmación manual, que la evaluación del sobrecosto sigue siendo responsabilidad de Administración y Finanzas, y que la automatización de control de gastos utiliza un umbral de 80 % para el estado CERCA y de 100 % para SUPERADO.
