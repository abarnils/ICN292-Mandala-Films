# 03 — Modelo de datos (ER en 3FN) y diccionario de datos

Motor: PostgreSQL 16. Script de creación: `schema.sql`. Datos de prueba: `seed.sql`.
Convenciones: las PK son `INTEGER GENERATED ALWAYS AS IDENTITY`; los montos están en pesos chilenos sin decimales (`BIGINT`); el IVA es 19 %. "UK" = restricción UNIQUE.

## 1. Resumen del modelo

17 tablas y 5 vistas.

| Grupo | Tablas |
|---|---|
| Catálogos | ETAPA, ROL, TIPO_HITO, CATEGORIA_GASTO |
| Núcleo comercial | CLIENTE, PROYECTO, COTIZACION, ORDEN_COMPRA |
| Equipo y planificación | EMPLEADO, ASIGNACION_PROYECTO, HITO |
| Costos | GASTO |
| Documentos, facturación y pagos | DOCUMENTO, FACTURA, PAGO |
| Indicadores y acceso | INDICADOR_FINANCIERO, USUARIO |

Relaciones principales: CLIENTE 1–N PROYECTO 1–N COTIZACION 1–0..1 ORDEN_COMPRA 1–N FACTURA 1–N PAGO. FACTURA se respalda en un DOCUMENTO (HES/MIGO) del mismo proyecto.

## 2. Diccionario de datos

### CLIENTE
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_cliente | INTEGER | No | PK | Identidad |
| rut | VARCHAR(12) | No | UK | Formato `12345678-9` (CHECK); dígito verificador: backend (R07) |
| nombre | VARCHAR(150) | No | | |
| email | VARCHAR(150) | Sí | | Atómico (1FN) |
| telefono | VARCHAR(20) | Sí | | Atómico (1FN) |

### ETAPA
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_etapa | INTEGER | No | PK | |
| nombre | VARCHAR(50) | No | UK | Incluye la etapa inicial «Cotización» |

### PROYECTO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_proyecto | INTEGER | No | PK | |
| id_cliente | INTEGER | No | FK → cliente | ON DELETE RESTRICT (R10) |
| id_etapa_actual | INTEGER | No | FK → etapa | Reemplaza al texto libre `estado_actual` (R11); el avance lo confirma el productor (R12) |
| nombre_proyecto | VARCHAR(150) | No | UK compuesta (id_cliente, nombre_proyecto) | |
| fecha_inicio | DATE | No | | |

### COTIZACION
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_cotizacion | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | ON DELETE RESTRICT |
| monto | BIGINT | No | | CHECK > 0 (R06). Si está APROBADA, es el presupuesto del proyecto |
| estado | VARCHAR(12) | No | | CHECK en (`PENDIENTE`, `APROBADA`, `RECHAZADA`) (R11) |
| fecha | DATE | No | | |

Índice único parcial `(id_proyecto) WHERE estado = 'APROBADA'`: máximo una cotización aprobada por proyecto (R01).

### ORDEN_COMPRA
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_oc | INTEGER | No | PK | |
| id_cotizacion | INTEGER | No | FK → cotizacion, UK | Una cotización tiene como máximo una OC (R03). Trigger: la cotización debe estar APROBADA (R02) |
| numero_oc | VARCHAR(30) | No | UK | |
| fecha_recepcion | DATE | No | | |

### ROL
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_rol | INTEGER | No | PK | |
| nombre | VARCHAR(50) | No | UK | Evita variantes de escritura (R11) |

### EMPLEADO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_empleado | INTEGER | No | PK | |
| id_rol | INTEGER | No | FK → rol | |
| nombre | VARCHAR(150) | No | | |
| tarifa_base | BIGINT | No | | CHECK > 0. Propia del empleado, no del rol (supuesto 2) |

### ASIGNACION_PROYECTO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_asignacion | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | |
| id_empleado | INTEGER | No | FK → empleado | |
| id_rol | INTEGER | No | FK → rol | |
| jornadas | NUMERIC(6,2) | No | | CHECK > 0 |
| tarifa_pactada | BIGINT | No | | CHECK > 0 |

UK `(id_proyecto, id_empleado, id_rol)`: un empleado no repite el mismo rol en un proyecto (R08). El honorario no se almacena: `v_asignacion_honorario`.

### TIPO_HITO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_tipo_hito | INTEGER | No | PK | |
| id_etapa | INTEGER | No | FK → etapa | La etapa depende del tipo de hito (3FN) |
| nombre | VARCHAR(80) | No | UK | |

### HITO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_hito | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | |
| id_tipo_hito | INTEGER | No | FK → tipo_hito | |
| fecha_inicio_programada | DATE | No | | |
| fecha_fin_programada | DATE | No | | CHECK ≥ inicio (R06); permite la Gantt (RF07) |
| fecha_cumplimiento | DATE | Sí | | Nula mientras no se cumple. El estado se calcula en `v_hito_estado` |

### CATEGORIA_GASTO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_categoria | INTEGER | No | PK | |
| nombre | VARCHAR(80) | No | UK | |
| tipo | VARCHAR(10) | No | | CHECK en (`FIJO`, `VARIABLE`) (R11) |

### GASTO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_gasto | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | |
| id_categoria | INTEGER | No | FK → categoria_gasto | El tipo se obtiene de la categoría |
| descripcion | VARCHAR(255) | Sí | | |
| monto | BIGINT | No | | CHECK > 0 |
| fecha | DATE | No | | |

### DOCUMENTO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_documento | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | |
| tipo | VARCHAR(20) | No | | CHECK en (`GUION`, `HES`, `MIGO`, `PRODUCTO_FINAL`) (R11) |
| version | INTEGER | No | | CHECK > 0, por defecto 1 |
| estado_aprobacion | VARCHAR(12) | No | | CHECK en (`PENDIENTE`, `APROBADO`, `RECHAZADO`) |
| fecha | DATE | No | | |
| referencia | VARCHAR(100) | Sí | | |

### FACTURA
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_factura | INTEGER | No | PK | |
| id_oc | INTEGER | No | FK → orden_compra | NOT NULL: toda factura exige OC (R04) |
| id_documento_hes | INTEGER | No | FK → documento, UK | Un HES/MIGO respalda como máximo una factura (R05) |
| numero_factura | VARCHAR(30) | No | UK | Folio de facturacion.cl |
| monto_neto | BIGINT | No | | CHECK > 0 |
| fecha_emision | DATE | No | | |

Trigger (R04): el documento debe ser HES o MIGO, estar APROBADO y pertenecer al mismo proyecto que la OC. El proyecto no se guarda en FACTURA: se obtiene en `v_factura`. IVA, total, pagado y saldo salen de la misma vista.

### PAGO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_pago | INTEGER | No | PK | |
| id_factura | INTEGER | No | FK → factura | |
| tipo | VARCHAR(10) | No | | CHECK en (`ANTICIPO`, `FINAL`) |
| monto | BIGINT | No | | CHECK > 0. La suma de pagos no debe superar el total de la factura (R14, backend) |
| fecha_recepcion | DATE | No | | |

### INDICADOR_FINANCIERO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_kpi | INTEGER | No | PK | |
| id_proyecto | INTEGER | No | FK → proyecto | |
| tipo_calculo | VARCHAR(10) | No | | CHECK en (`ESTIMADO`, `REAL`) |
| fecha_calculo | DATE | No | | |
| ingreso_neto | BIGINT | No | | CHECK ≥ 0 |
| honorarios_total | BIGINT | No | | CHECK ≥ 0 |
| costos_fijos | BIGINT | No | | CHECK ≥ 0 |
| costos_variables | BIGINT | No | | CHECK ≥ 0 |

UK `(id_proyecto, tipo_calculo)`: a lo más un ESTIMADO y un REAL por proyecto (R09). Guarda solo los insumos congelados; IVA, EBITDA y margen salen de `v_indicador_financiero`.

### USUARIO
| Atributo | Tipo | Nulo | Clave | Regla |
|---|---|---|---|---|
| id_usuario | INTEGER | No | PK | |
| nombre | VARCHAR(150) | No | | |
| email | VARCHAR(150) | No | UK | |
| password_hash | VARCHAR(255) | No | | Nunca se guarda la contraseña en claro |
| rol_acceso | VARCHAR(20) | No | | CHECK en (`DUENO`, `ADMIN_FINANZAS`) (R16) |

## 3. Vistas

| Vista | Qué calcula |
|---|---|
| v_presupuesto_proyecto | Presupuesto (monto de la cotización APROBADA), gasto total, porcentaje gastado y alerta de sobrecosto desde el 90 % (R15) |
| v_asignacion_honorario | Honorario = jornadas × tarifa_pactada |
| v_hito_estado | Estado del hito: CUMPLIDO, ATRASADO, EN_CURSO o PENDIENTE, según las fechas |
| v_factura | Proyecto de la factura (vía OC → cotización), IVA (19 %), total, pagado y saldo (R14) |
| v_indicador_financiero | IVA, EBITDA y margen % a partir de los insumos guardados |

## 4. Reglas de integridad

| ID | Regla | Dónde se aplica |
|---|---|---|
| R01 | Un proyecto tiene como máximo una cotización aprobada (su presupuesto) | BD: índice único parcial |
| R02 | Una OC solo existe si su cotización está APROBADA | BD: trigger |
| R03 | Una cotización tiene como máximo una OC | BD: UNIQUE |
| R04 | Una factura exige OC y un HES/MIGO APROBADO del mismo proyecto | BD: NOT NULL + trigger |
| R05 | Un HES/MIGO respalda como máximo una factura | BD: UNIQUE |
| R06 | Montos, jornadas y versiones positivos; fechas fin ≥ inicio | BD: CHECK |
| R07 | RUT único y con formato válido | BD: UNIQUE + CHECK (dígito verificador: backend) |
| R08 | Un empleado no repite el mismo rol en el mismo proyecto | BD: UNIQUE |
| R09 | Un proyecto tiene como máximo un indicador ESTIMADO y uno REAL | BD: UNIQUE |
| R10 | No se borran registros con dependientes | BD: FK sin cascada |
| R11 | Etapas, estados y tipos solo admiten valores del dominio | BD: FK a catálogo o CHECK |
| R12 | El avance de etapa lo confirma manualmente el productor | Backend |
| R13 | Al aceptar la cotización se crea el indicador ESTIMADO; al cierre, el REAL | Backend |
| R14 | La suma de pagos no debe superar el total de la factura | Backend (`v_factura.saldo` permite detectarlo) |
| R15 | Alerta de sobrecosto al llegar al 90 % del presupuesto | Vista `v_presupuesto_proyecto` (umbral supuesto) |
| R16 | Solo DUENO y ADMIN_FINANZAS acceden al sistema | BD: CHECK + backend |

## 5. Verificación de normalización

- **1FN:** todos los atributos son atómicos y cada tabla tiene PK.
- **2FN:** todas las PK son de una sola columna, por lo que no hay dependencias parciales.
- **3FN:** en cada tabla los únicos determinantes son claves candidatas.
- **Excepción consciente:** INDICADOR_FINANCIERO guarda ingreso, honorarios y costos que podrían recalcularse. Se conservan como foto histórica porque el indicador estimado se fija al aceptar la cotización y no debe cambiar después.

## 6. Supuestos

1. El proyecto nace en la etapa «Cotización» y pasa a Preproducción al aceptarse la cotización.
2. La tarifa base es propia de cada empleado, no del rol.
3. La alerta de sobrecosto compara el gasto con el monto de la cotización aprobada y se activa desde el 90 %.
4. El IVA es 19 % y los montos están en pesos chilenos sin decimales.
5. Etapas del proyecto (según E1): Cotización (inicial), Preproducción, Grabación, Postproducción y Cierre. Tipos de documento (según E1): guion, HES, MIGO y producto final.
