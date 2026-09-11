#SIG — Mandala Films

Sistema de Información para la Gestión de proyectos audiovisuales — Productora Audiovisual Mandala Films Ltda.

Proyecto de la asignatura *ICN292 — Sistemas de Información para la Gestión (2026-2)*, Universidad Técnica Federico Santa María, Campus Vitacura. Entrega 1 (E1): diagnóstico, requerimientos y diseño preliminar.

#La PYME y el Problema
Mandala Films es una pequeña productora audiovisual ubicada en Providencia dedicada a producción de películas, videos y programas de televisión.

Hoy el seguimiento de cada proyecto desde la cotización hasta el cierre y facturación se maneja de forma manual y dispersa (planillas de Excel, calendario, WhatsApp, correo y pizarra). Esto genera que la información se desordene y que encontrar el estado real de un proyecto tome tiempo innecesario (el dueño estima un desgaste de 3 a 5 horas por proyecto en reconstruir información y corregir errores).

El SIG propuesto busca reemplazar ese seguimiento disperso por un sistema centralizado que permita visualizar en tiempo real la etapa de cada proyecto (preproducción, grabación, postproducción, cierre) junto con sus datos financieros (costos, honorarios, IVA, EBITDA, márgenes), y entregar visibilidad consolidada mediante un dashboard de KPIs.

Detalle completo en docs/00-caso-pyme.md.

README.md              # este archivo
docs/
  00-caso-pyme.md      # identificación de la PYME, evidencia, problema y objetivo del SIG
  01-requerimientos.md # actores, alcance in/out, requisitos funcionales y no funcionales
  02-bpmn.md           # procesos AS-IS y TO-BE, explicación de mejoras
  03-er-preliminar.md  # modelo de datos preliminar
assets/                # diagramas exportados (BPMN AS-IS/TO-BE, modelo ER, arquitectura)
informe/               # informe completo en PDF y Word/LaTeX (mismo contenido que en Aula)

#Relacion con la Entrega 2

Esta entrega define el diseño (problema, requerimientos, procesos y modelo de datos preliminar) que la Entrega 2 usará como base para construir una versión funcional ejecutable en localhost, según el stack tentativo definido en el informe (sección "Arquitectura lógica y stack tentativo").

#Equipo

Agustín Barnils / 202360650-2 / Responsable Parte B y C (PYME/problema y requerimientos)
Paula Daroch / xxxxxxxxx-x / 
Catalina Jofre / xxxxxxxxx-x /
Antar Pizarro / xxxxxxxxx-x / 
Antonella Dagnino / xxxxxxxxx-x / 
