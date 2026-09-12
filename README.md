# SIG / Mandala Films

Sistema de Información para la Gestión de proyectos audiovisuales — Productora Audiovisual Mandala Films Ltda.

Proyecto de la asignatura *ICN292 — Sistemas de Información para la Gestión (2026-2)*, Universidad Técnica Federico Santa María, Campus Vitacura. Entrega 1: diagnóstico, requerimientos y diseño preliminar.

# La PYME y el Problema
Mandala Films es una pequeña productora audiovisual ubicada en Providencia dedicada a producción de películas, videos y programas de televisión.

Hoy el seguimiento de cada proyecto desde la cotización hasta el cierre y facturación se maneja de forma manual y dispersa (planillas de Excel, calendario, WhatsApp, correo y pizarra). Esto genera que la información se desordene y que encontrar el estado real de un proyecto tome tiempo innecesario (el dueño estima un desgaste de 3 a 5 horas por proyecto en reconstruir información y corregir errores).

El SIG propuesto busca reemplazar ese seguimiento disperso por un sistema centralizado que permita visualizar en tiempo real la etapa de cada proyecto (preproducción, grabación, postproducción, cierre) junto con sus datos financieros (costos, honorarios, IVA, EBITDA, márgenes), y entregar visibilidad consolidada mediante un dashboard de KPIs.

Detalle completo en docs/00-caso-pyme.md.

# Orden del repositorio

README.md              &nbsp; # este archivo<br>
docs/
  00-caso-pyme.md      &nbsp; # identificación de la PYME, evidencia, problema y objetivo del SIG<br>
  01-requerimientos.md &nbsp; # actores, alcance in/out, requisitos funcionales y no funcionales<br>
  02-bpmn.md           &nbsp; # procesos AS-IS y TO-BE, explicación de mejoras<br>
  03-er-preliminar.md  &nbsp; # modelo de datos preliminar<br>
assets/                &nbsp; # diagramas exportados (BPMN AS-IS/TO-BE, modelo ER, arquitectura)<br>
informe/               &nbsp; # informe completo en PDF y Word/LaTeX (mismo contenido que en Aula)<br>

# Relacion con la Entrega 2

Esta entrega define el diseño (problema, requerimientos, procesos y modelo de datos preliminar) que la Entrega 2 usará como base para construir una versión funcional ejecutable en localhost, según el stack tentativo definido en el informe (sección "Arquitectura lógica y stack tentativo").

# Equipo

Agustín Barnils / 202360650-2 / Responsable Parte B y C (PYME/problema y requerimientos)<br>
Paula Daroch / 202266510-6 / Responsable Modelo As-Is y Parte G.<br>
Catalina Jofre / xxxxxxxxx-x / xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx<br>
Antar Pizarro / 202260576-6 / Responsable parte F (Arquitectura lógica y stack)<br>
Antonella Dagnino / 202210025-7 / Responsable parte E datos preliminar<br>
