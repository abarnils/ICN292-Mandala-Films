-- schema.sql - SIG Mandala Films (PostgreSQL 16)

DROP VIEW IF EXISTS v_indicador_financiero, v_factura, v_hito_estado,
                    v_asignacion_honorario, v_presupuesto_proyecto CASCADE;

DROP TABLE IF EXISTS pago, factura, documento, gasto, categoria_gasto,
                     hito, tipo_hito, asignacion_proyecto, empleado, rol,
                     indicador_financiero, orden_compra, cotizacion,
                     proyecto, etapa, cliente, usuario CASCADE;

DROP FUNCTION IF EXISTS fn_valida_oc_cotizacion_aprobada() CASCADE;
DROP FUNCTION IF EXISTS fn_valida_factura() CASCADE;

CREATE TABLE etapa (
    id_etapa  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE rol (
    id_rol  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE tipo_hito (
    id_tipo_hito  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_etapa      INTEGER NOT NULL REFERENCES etapa(id_etapa) ON DELETE RESTRICT,
    nombre        VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE categoria_gasto (
    id_categoria  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL UNIQUE,
    tipo          VARCHAR(10) NOT NULL CHECK (tipo IN ('FIJO', 'VARIABLE'))
);

CREATE TABLE cliente (
    id_cliente  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rut         VARCHAR(12) NOT NULL UNIQUE
                CHECK (rut ~ '^[0-9]{7,8}-[0-9Kk]$'),
    nombre      VARCHAR(150) NOT NULL,
    email       VARCHAR(150),
    telefono    VARCHAR(20)
);

CREATE TABLE proyecto (
    id_proyecto       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente        INTEGER NOT NULL REFERENCES cliente(id_cliente) ON DELETE RESTRICT,
    id_etapa_actual   INTEGER NOT NULL REFERENCES etapa(id_etapa)     ON DELETE RESTRICT,
    nombre_proyecto   VARCHAR(150) NOT NULL,
    fecha_inicio      DATE NOT NULL,
    CONSTRAINT uq_proyecto_cliente_nombre UNIQUE (id_cliente, nombre_proyecto)
);

CREATE TABLE cotizacion (
    id_cotizacion  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto    INTEGER NOT NULL REFERENCES proyecto(id_proyecto) ON DELETE RESTRICT,
    monto          BIGINT  NOT NULL CHECK (monto > 0),
    estado         VARCHAR(12) NOT NULL DEFAULT 'PENDIENTE'
                   CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')),
    fecha          DATE NOT NULL
);

CREATE UNIQUE INDEX uq_cotizacion_aprobada_por_proyecto
    ON cotizacion (id_proyecto) WHERE estado = 'APROBADA';

CREATE TABLE orden_compra (
    id_oc            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cotizacion    INTEGER NOT NULL UNIQUE
                     REFERENCES cotizacion(id_cotizacion) ON DELETE RESTRICT,
    numero_oc        VARCHAR(30) NOT NULL UNIQUE,
    fecha_recepcion  DATE NOT NULL
);

CREATE FUNCTION fn_valida_oc_cotizacion_aprobada() RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cotizacion
                   WHERE id_cotizacion = NEW.id_cotizacion
                     AND estado = 'APROBADA') THEN
        RAISE EXCEPTION 'R02: la cotización % no está APROBADA; no se puede registrar la OC',
                        NEW.id_cotizacion;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_oc_cotizacion_aprobada
    BEFORE INSERT OR UPDATE OF id_cotizacion ON orden_compra
    FOR EACH ROW EXECUTE FUNCTION fn_valida_oc_cotizacion_aprobada();

CREATE TABLE empleado (
    id_empleado  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_rol       INTEGER NOT NULL REFERENCES rol(id_rol) ON DELETE RESTRICT,
    nombre       VARCHAR(150) NOT NULL,
    tarifa_base  BIGINT NOT NULL CHECK (tarifa_base > 0)
);

CREATE TABLE asignacion_proyecto (
    id_asignacion   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto     INTEGER NOT NULL REFERENCES proyecto(id_proyecto) ON DELETE RESTRICT,
    id_empleado     INTEGER NOT NULL REFERENCES empleado(id_empleado) ON DELETE RESTRICT,
    id_rol          INTEGER NOT NULL REFERENCES rol(id_rol)           ON DELETE RESTRICT,
    jornadas        NUMERIC(6,2) NOT NULL CHECK (jornadas > 0),
    tarifa_pactada  BIGINT NOT NULL CHECK (tarifa_pactada > 0),
    CONSTRAINT uq_asignacion UNIQUE (id_proyecto, id_empleado, id_rol)
);

CREATE TABLE hito (
    id_hito                  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto              INTEGER NOT NULL REFERENCES proyecto(id_proyecto)   ON DELETE RESTRICT,
    id_tipo_hito             INTEGER NOT NULL REFERENCES tipo_hito(id_tipo_hito) ON DELETE RESTRICT,
    fecha_inicio_programada  DATE NOT NULL,
    fecha_fin_programada     DATE NOT NULL,
    fecha_cumplimiento       DATE,
    CONSTRAINT ck_hito_fechas CHECK (fecha_fin_programada >= fecha_inicio_programada)
);

CREATE TABLE gasto (
    id_gasto      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto   INTEGER NOT NULL REFERENCES proyecto(id_proyecto)        ON DELETE RESTRICT,
    id_categoria  INTEGER NOT NULL REFERENCES categoria_gasto(id_categoria) ON DELETE RESTRICT,
    descripcion   VARCHAR(255),
    monto         BIGINT NOT NULL CHECK (monto > 0),
    fecha         DATE NOT NULL
);

CREATE TABLE documento (
    id_documento       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto        INTEGER NOT NULL REFERENCES proyecto(id_proyecto) ON DELETE RESTRICT,
    tipo               VARCHAR(20) NOT NULL
                       CHECK (tipo IN ('GUION', 'HES', 'MIGO', 'PRODUCTO_FINAL')),
    version            INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    estado_aprobacion  VARCHAR(12) NOT NULL DEFAULT 'PENDIENTE'
                       CHECK (estado_aprobacion IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),
    fecha              DATE NOT NULL,
    referencia         VARCHAR(100)
);

CREATE TABLE factura (
    id_factura         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_oc              INTEGER NOT NULL REFERENCES orden_compra(id_oc)   ON DELETE RESTRICT,
    id_documento_hes   INTEGER NOT NULL UNIQUE
                       REFERENCES documento(id_documento) ON DELETE RESTRICT,
    numero_factura     VARCHAR(30) NOT NULL UNIQUE,
    monto_neto         BIGINT NOT NULL CHECK (monto_neto > 0),
    fecha_emision      DATE NOT NULL
);

CREATE FUNCTION fn_valida_factura() RETURNS trigger AS $$
DECLARE
    v_proy_oc   INTEGER;
    v_proy_doc  INTEGER;
    v_tipo      VARCHAR;
    v_estado    VARCHAR;
BEGIN
    SELECT c.id_proyecto INTO v_proy_oc
      FROM orden_compra oc JOIN cotizacion c ON c.id_cotizacion = oc.id_cotizacion
     WHERE oc.id_oc = NEW.id_oc;

    SELECT d.id_proyecto, d.tipo, d.estado_aprobacion
      INTO v_proy_doc, v_tipo, v_estado
      FROM documento d WHERE d.id_documento = NEW.id_documento_hes;

    IF v_tipo NOT IN ('HES', 'MIGO') THEN
        RAISE EXCEPTION 'R04: el documento % es de tipo %, se exige HES o MIGO',
                        NEW.id_documento_hes, v_tipo;
    END IF;
    IF v_estado <> 'APROBADO' THEN
        RAISE EXCEPTION 'R04: el documento % no está APROBADO (estado: %)',
                        NEW.id_documento_hes, v_estado;
    END IF;
    IF v_proy_oc IS DISTINCT FROM v_proy_doc THEN
        RAISE EXCEPTION 'R04: la OC (proyecto %) y el HES/MIGO (proyecto %) son de proyectos distintos',
                        v_proy_oc, v_proy_doc;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_factura_valida
    BEFORE INSERT OR UPDATE OF id_oc, id_documento_hes ON factura
    FOR EACH ROW EXECUTE FUNCTION fn_valida_factura();

CREATE TABLE pago (
    id_pago          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura       INTEGER NOT NULL REFERENCES factura(id_factura) ON DELETE RESTRICT,
    tipo             VARCHAR(10) NOT NULL CHECK (tipo IN ('ANTICIPO', 'FINAL')),
    monto            BIGINT NOT NULL CHECK (monto > 0),
    fecha_recepcion  DATE NOT NULL
);

CREATE TABLE indicador_financiero (
    id_kpi            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_proyecto       INTEGER NOT NULL REFERENCES proyecto(id_proyecto) ON DELETE RESTRICT,
    tipo_calculo      VARCHAR(10) NOT NULL CHECK (tipo_calculo IN ('ESTIMADO', 'REAL')),
    fecha_calculo     DATE NOT NULL,
    ingreso_neto      BIGINT NOT NULL CHECK (ingreso_neto >= 0),
    honorarios_total  BIGINT NOT NULL CHECK (honorarios_total >= 0),
    costos_fijos      BIGINT NOT NULL CHECK (costos_fijos >= 0),
    costos_variables  BIGINT NOT NULL CHECK (costos_variables >= 0),
    CONSTRAINT uq_indicador_tipo UNIQUE (id_proyecto, tipo_calculo)
);

CREATE TABLE usuario (
    id_usuario     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre         VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    rol_acceso     VARCHAR(20) NOT NULL
                   CHECK (rol_acceso IN ('DUENO', 'ADMIN_FINANZAS'))
);

CREATE VIEW v_presupuesto_proyecto AS
SELECT p.id_proyecto,
       p.nombre_proyecto,
       c.monto                                  AS presupuesto,
       COALESCE(SUM(g.monto), 0)                AS gasto_total,
       ROUND(COALESCE(SUM(g.monto), 0) * 100.0 / c.monto, 1) AS porcentaje_gastado,
       (COALESCE(SUM(g.monto), 0) >= 0.90 * c.monto)         AS alerta_sobrecosto
FROM proyecto p
JOIN cotizacion c ON c.id_proyecto = p.id_proyecto AND c.estado = 'APROBADA'
LEFT JOIN gasto g ON g.id_proyecto = p.id_proyecto
GROUP BY p.id_proyecto, p.nombre_proyecto, c.monto;

CREATE VIEW v_asignacion_honorario AS
SELECT a.id_asignacion,
       a.id_proyecto,
       a.id_empleado,
       a.id_rol,
       a.jornadas,
       a.tarifa_pactada,
       ROUND(a.jornadas * a.tarifa_pactada) AS honorario
FROM asignacion_proyecto a;

CREATE VIEW v_hito_estado AS
SELECT h.*,
       CASE
           WHEN h.fecha_cumplimiento IS NOT NULL                   THEN 'CUMPLIDO'
           WHEN CURRENT_DATE > h.fecha_fin_programada              THEN 'ATRASADO'
           WHEN CURRENT_DATE >= h.fecha_inicio_programada          THEN 'EN_CURSO'
           ELSE 'PENDIENTE'
       END AS estado
FROM hito h;

CREATE VIEW v_factura AS
SELECT f.id_factura,
       f.numero_factura,
       c.id_proyecto,
       f.id_oc,
       f.monto_neto,
       ROUND(f.monto_neto * 0.19)                         AS iva,
       f.monto_neto + ROUND(f.monto_neto * 0.19)          AS total,
       COALESCE(SUM(pg.monto), 0)                         AS pagado,
       f.monto_neto + ROUND(f.monto_neto * 0.19)
           - COALESCE(SUM(pg.monto), 0)                   AS saldo
FROM factura f
JOIN orden_compra oc ON oc.id_oc = f.id_oc
JOIN cotizacion  c   ON c.id_cotizacion = oc.id_cotizacion
LEFT JOIN pago   pg  ON pg.id_factura = f.id_factura
GROUP BY f.id_factura, f.numero_factura, c.id_proyecto, f.id_oc, f.monto_neto;

CREATE VIEW v_indicador_financiero AS
SELECT i.*,
       ROUND(i.ingreso_neto * 0.19)                                      AS iva,
       i.ingreso_neto - i.honorarios_total
           - i.costos_fijos - i.costos_variables                         AS ebitda,
       CASE WHEN i.ingreso_neto = 0 THEN NULL
            ELSE ROUND((i.ingreso_neto - i.honorarios_total
                        - i.costos_fijos - i.costos_variables) * 100.0
                       / i.ingreso_neto, 1)
       END                                                               AS margen_pct
FROM indicador_financiero i;

INSERT INTO etapa (nombre) VALUES
    ('Cotización'),
    ('Preproducción'),
    ('Grabación'),
    ('Postproducción'),
    ('Cierre');
