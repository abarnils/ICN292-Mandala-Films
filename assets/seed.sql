-- =====================================================================
-- seed.sql  |  Datos de prueba SINTÉTICOS para el SIG de Mandala Films
-- Requiere haber ejecutado antes schema.sql (que crea las etapas).
-- Orden de uso:   psql -f schema.sql   y luego   psql -f seed.sql
-- Todos los clientes, personas y folios son ficticios. Montos en CLP.
-- Los FK se resuelven por clave natural (nombre), no por id fijo.
--
-- Casos de negocio que cubre:
--   * Proyecto con cotización rechazada y una nueva pendiente (Serie de reels)
--   * Proyecto cerrado y pagado en dos cuotas, con EBITDA ESTIMADO y REAL
--   * Proyecto cerrado con factura y solo anticipo pagado (saldo por cobrar)
--   * Proyecto en alerta de sobrecosto (gasto >= 90 % del presupuesto)
--   * Hitos cumplidos, en curso, pendientes y atrasados
-- =====================================================================

-- ---------- Catálogos -------------------------------------------------
INSERT INTO rol (nombre) VALUES
    ('Productor'), ('Director'), ('Camarógrafo'), ('Editor'),
    ('Guionista'), ('Diseñador gráfico'), ('Locutor'), ('Asistente');

INSERT INTO tipo_hito (id_etapa, nombre)
SELECT e.id_etapa, v.nombre
FROM (VALUES
    ('Preproducción',  'Visita a locación'),
    ('Preproducción',  'Confirmación de equipo'),
    ('Grabación',      'Jornada de grabación'),
    ('Postproducción', 'Locución'),
    ('Postproducción', 'Diseño gráfico'),
    ('Postproducción', 'Montaje'),
    ('Cierre',         'Entrega de producto final'),
    ('Cierre',         'Cierre financiero')
) AS v(etapa, nombre)
JOIN etapa e ON e.nombre = v.etapa;

INSERT INTO categoria_gasto (nombre, tipo) VALUES
    ('Arriendo de equipos',  'FIJO'),
    ('Arriendo de estudio',  'FIJO'),
    ('Licencia de música',   'FIJO'),
    ('Bencina',              'VARIABLE'),
    ('Alimentación',         'VARIABLE'),
    ('Peajes y estacionamiento', 'VARIABLE'),
    ('Catering',             'VARIABLE');

-- ---------- Clientes y empleados -------------------------------------
INSERT INTO cliente (rut, nombre, email, telefono) VALUES
    ('76123450-1', 'Constructora Los Aromos SpA',   'contacto@losaromos.test',    '+56 9 5550 1001'),
    ('76234560-9', 'Cervecería Andes Sur Ltda.',    'marketing@andessur.test',    '+56 9 5550 1002'),
    ('76345670-6', 'Clínica Vista Norte S.A.',      'comunicaciones@vistanorte.test', '+56 2 2555 1003'),
    ('65432190-6', 'Fundación Mar Abierto',         'proyectos@marabierto.test',  '+56 9 5550 1004');

INSERT INTO empleado (id_rol, nombre, tarifa_base)
SELECT r.id_rol, v.nombre, v.tarifa
FROM (VALUES
    ('Productor',         'Camila Rojas',     130000),
    ('Director',          'Diego Fuentes',    150000),
    ('Camarógrafo',       'Matías Vera',      110000),
    ('Editor',            'Sofía Lagos',      100000),
    ('Guionista',         'Tomás Araya',       90000),
    ('Diseñador gráfico', 'Valentina Pino',    85000),
    ('Locutor',           'Ignacio Mella',     80000),
    ('Asistente',         'Renata Cortés',     60000)
) AS v(rol, nombre, tarifa)
JOIN rol r ON r.nombre = v.rol;

-- ---------- Proyectos -------------------------------------------------
-- Todos nacen en «Cotización»; el avance de etapa se confirma después (R12).
INSERT INTO proyecto (id_cliente, id_etapa_actual, nombre_proyecto, fecha_inicio)
SELECT c.id_cliente, e.id_etapa, v.proyecto, v.inicio::date
FROM (VALUES
    ('76123450-1', 'Cierre',         'Spot institucional Aromos',          '2026-05-04'),
    ('76234560-9', 'Postproducción', 'Video corporativo Andes Sur',        '2026-08-10'),
    ('76345670-6', 'Grabación',      'Documental Clínica Vista Norte',     '2026-10-05'),
    ('76123450-1', 'Cotización',     'Serie de reels Aromos',              '2026-10-19'),
    ('65432190-6', 'Preproducción',  'Cobertura aniversario Mar Abierto',  '2026-11-16'),
    ('65432190-6', 'Cierre',         'Cápsulas educativas Mar Abierto',    '2026-03-02')
) AS v(rut, etapa, proyecto, inicio)
JOIN cliente c ON c.rut = v.rut
JOIN etapa   e ON e.nombre = v.etapa;

-- ---------- Cotizaciones y órdenes de compra --------------------------
INSERT INTO cotizacion (id_proyecto, monto, estado, fecha)
SELECT p.id_proyecto, v.monto, v.estado, v.fecha::date
FROM (VALUES
    ('Spot institucional Aromos',         8500000, 'APROBADA',  '2026-04-20'),
    ('Video corporativo Andes Sur',       9000000, 'APROBADA',  '2026-08-03'),
    ('Documental Clínica Vista Norte',   15000000, 'APROBADA',  '2026-09-28'),
    ('Serie de reels Aromos',             7000000, 'RECHAZADA', '2026-10-05'),
    ('Serie de reels Aromos',             5500000, 'PENDIENTE', '2026-10-19'),
    ('Cobertura aniversario Mar Abierto', 4200000, 'APROBADA',  '2026-11-09'),
    ('Cápsulas educativas Mar Abierto',   6000000, 'APROBADA',  '2026-02-20')
) AS v(proyecto, monto, estado, fecha)
JOIN proyecto p ON p.nombre_proyecto = v.proyecto;

INSERT INTO orden_compra (id_cotizacion, numero_oc, fecha_recepcion)
SELECT c.id_cotizacion, v.numero_oc, v.fecha::date
FROM (VALUES
    ('Spot institucional Aromos',         'OC-2026-0412', '2026-05-02'),
    ('Video corporativo Andes Sur',       'OC-2026-0587', '2026-08-07'),
    ('Documental Clínica Vista Norte',    'OC-2026-0733', '2026-10-01'),
    ('Cobertura aniversario Mar Abierto', 'OC-2026-0801', '2026-11-12'),
    ('Cápsulas educativas Mar Abierto',   'OC-2026-0155', '2026-02-27')
) AS v(proyecto, numero_oc, fecha)
JOIN proyecto   p ON p.nombre_proyecto = v.proyecto
JOIN cotizacion c ON c.id_proyecto = p.id_proyecto AND c.estado = 'APROBADA';

-- ---------- Asignaciones (jornadas × tarifa pactada = honorario) ------
INSERT INTO asignacion_proyecto (id_proyecto, id_empleado, id_rol, jornadas, tarifa_pactada)
SELECT p.id_proyecto, e.id_empleado, r.id_rol, v.jornadas, v.tarifa
FROM (VALUES
    -- Spot institucional Aromos
    ('Spot institucional Aromos', 'Camila Rojas',   'Productor',   10, 130000),
    ('Spot institucional Aromos', 'Matías Vera',    'Camarógrafo',  4, 110000),
    ('Spot institucional Aromos', 'Sofía Lagos',    'Editor',       6, 100000),
    ('Spot institucional Aromos', 'Tomás Araya',    'Guionista',    3,  90000),
    ('Spot institucional Aromos', 'Ignacio Mella',  'Locutor',      1,  80000),
    -- Video corporativo Andes Sur
    ('Video corporativo Andes Sur', 'Camila Rojas',    'Productor',         12, 130000),
    ('Video corporativo Andes Sur', 'Diego Fuentes',   'Director',           3, 150000),
    ('Video corporativo Andes Sur', 'Matías Vera',     'Camarógrafo',        5, 110000),
    ('Video corporativo Andes Sur', 'Sofía Lagos',     'Editor',             8, 105000),
    ('Video corporativo Andes Sur', 'Valentina Pino',  'Diseñador gráfico',  4,  85000),
    -- Documental Clínica Vista Norte
    ('Documental Clínica Vista Norte', 'Camila Rojas',   'Productor',   15, 130000),
    ('Documental Clínica Vista Norte', 'Diego Fuentes',  'Director',     4, 150000),
    ('Documental Clínica Vista Norte', 'Matías Vera',    'Camarógrafo',  8, 115000),
    ('Documental Clínica Vista Norte', 'Renata Cortés',  'Asistente',    8,  60000),
    -- Cobertura aniversario Mar Abierto
    ('Cobertura aniversario Mar Abierto', 'Camila Rojas',  'Productor',  4, 130000),
    ('Cobertura aniversario Mar Abierto', 'Renata Cortés', 'Asistente',  2,  60000),
    -- Cápsulas educativas Mar Abierto
    ('Cápsulas educativas Mar Abierto', 'Camila Rojas', 'Productor',    6, 130000),
    ('Cápsulas educativas Mar Abierto', 'Matías Vera',  'Camarógrafo',  3, 110000),
    ('Cápsulas educativas Mar Abierto', 'Sofía Lagos',  'Editor',       5, 100000)
) AS v(proyecto, empleado, rol, jornadas, tarifa)
JOIN proyecto p ON p.nombre_proyecto = v.proyecto
JOIN empleado e ON e.nombre = v.empleado
JOIN rol      r ON r.nombre = v.rol;

-- ---------- Hitos (Gantt). NULL en cumplimiento = aún no cumplido -----
INSERT INTO hito (id_proyecto, id_tipo_hito, fecha_inicio_programada, fecha_fin_programada, fecha_cumplimiento)
SELECT p.id_proyecto, t.id_tipo_hito, v.ini::date, v.fin::date, v.cumple::date
FROM (VALUES
    -- Spot institucional Aromos (todo cumplido)
    ('Spot institucional Aromos', 'Visita a locación',        '2026-05-11', '2026-05-13', '2026-05-12'),
    ('Spot institucional Aromos', 'Confirmación de equipo',   '2026-05-11', '2026-05-15', '2026-05-14'),
    ('Spot institucional Aromos', 'Jornada de grabación',     '2026-05-18', '2026-05-22', '2026-05-22'),
    ('Spot institucional Aromos', 'Locución',                 '2026-06-01', '2026-06-03', '2026-06-02'),
    ('Spot institucional Aromos', 'Diseño gráfico',           '2026-06-08', '2026-06-15', '2026-06-15'),
    ('Spot institucional Aromos', 'Montaje',                  '2026-06-01', '2026-06-19', '2026-06-18'),
    ('Spot institucional Aromos', 'Entrega de producto final','2026-06-22', '2026-06-26', '2026-06-25'),
    ('Spot institucional Aromos', 'Cierre financiero',        '2026-06-29', '2026-07-31', '2026-07-20'),
    -- Video corporativo Andes Sur (montaje sin cumplir y vencido)
    ('Video corporativo Andes Sur', 'Visita a locación',      '2026-08-17', '2026-08-19', '2026-08-18'),
    ('Video corporativo Andes Sur', 'Confirmación de equipo', '2026-08-17', '2026-08-21', '2026-08-20'),
    ('Video corporativo Andes Sur', 'Jornada de grabación',   '2026-08-31', '2026-09-11', '2026-09-11'),
    ('Video corporativo Andes Sur', 'Locución',               '2026-09-21', '2026-09-23', '2026-09-22'),
    ('Video corporativo Andes Sur', 'Diseño gráfico',         '2026-09-21', '2026-10-09', '2026-10-08'),
    ('Video corporativo Andes Sur', 'Montaje',                '2026-09-28', '2026-11-10', NULL),
    -- Documental Clínica Vista Norte (grabación en curso)
    ('Documental Clínica Vista Norte', 'Visita a locación',      '2026-10-12', '2026-10-14', '2026-10-13'),
    ('Documental Clínica Vista Norte', 'Confirmación de equipo', '2026-10-12', '2026-10-16', '2026-10-15'),
    ('Documental Clínica Vista Norte', 'Jornada de grabación',   '2026-11-16', '2026-12-04', NULL),
    ('Documental Clínica Vista Norte', 'Locución',               '2026-12-14', '2026-12-16', NULL),
    ('Documental Clínica Vista Norte', 'Montaje',                '2026-12-07', '2027-01-15', NULL),
    -- Cobertura aniversario Mar Abierto (preproducción)
    ('Cobertura aniversario Mar Abierto', 'Visita a locación',      '2026-11-23', '2026-11-27', NULL),
    ('Cobertura aniversario Mar Abierto', 'Confirmación de equipo', '2026-11-18', '2026-11-30', NULL),
    ('Cobertura aniversario Mar Abierto', 'Jornada de grabación',   '2026-12-07', '2026-12-08', NULL),
    -- Cápsulas educativas Mar Abierto (cerrado)
    ('Cápsulas educativas Mar Abierto', 'Visita a locación',        '2026-03-09', '2026-03-11', '2026-03-10'),
    ('Cápsulas educativas Mar Abierto', 'Confirmación de equipo',   '2026-03-09', '2026-03-13', '2026-03-12'),
    ('Cápsulas educativas Mar Abierto', 'Jornada de grabación',     '2026-03-23', '2026-03-27', '2026-03-27'),
    ('Cápsulas educativas Mar Abierto', 'Montaje',                  '2026-04-06', '2026-04-30', '2026-04-29'),
    ('Cápsulas educativas Mar Abierto', 'Entrega de producto final','2026-05-04', '2026-05-08', '2026-05-07'),
    ('Cápsulas educativas Mar Abierto', 'Cierre financiero',        '2026-05-11', '2026-06-15', '2026-06-15')
) AS v(proyecto, tipo, ini, fin, cumple)
JOIN proyecto  p ON p.nombre_proyecto = v.proyecto
JOIN tipo_hito t ON t.nombre = v.tipo;

-- ---------- Gastos ----------------------------------------------------
-- Video corporativo Andes Sur suma 8.150.000 sobre un presupuesto de
-- 9.000.000 (90,6 %): activa la alerta de sobrecosto (R15).
INSERT INTO gasto (id_proyecto, id_categoria, descripcion, monto, fecha)
SELECT p.id_proyecto, c.id_categoria, v.descripcion, v.monto, v.fecha::date
FROM (VALUES
    ('Spot institucional Aromos', 'Arriendo de equipos', 'Cámara y luces, 1 semana',     1800000, '2026-05-18'),
    ('Spot institucional Aromos', 'Licencia de música',  'Licencia pista musical',         250000, '2026-06-05'),
    ('Spot institucional Aromos', 'Bencina',             'Traslados a locación',            85000, '2026-05-19'),
    ('Spot institucional Aromos', 'Alimentación',        'Colaciones equipo',              120000, '2026-05-20'),

    ('Video corporativo Andes Sur', 'Arriendo de estudio',  'Estudio 5 días',             3200000, '2026-08-31'),
    ('Video corporativo Andes Sur', 'Arriendo de equipos',  'Cámaras, lentes y luces',    2900000, '2026-08-31'),
    ('Video corporativo Andes Sur', 'Licencia de música',   'Licencia pista musical',      780000, '2026-10-02'),
    ('Video corporativo Andes Sur', 'Catering',             'Catering jornadas de grabación', 700000, '2026-09-04'),
    ('Video corporativo Andes Sur', 'Alimentación',         'Colaciones equipo',           420000, '2026-09-08'),
    ('Video corporativo Andes Sur', 'Bencina',              'Traslados a locación',        150000, '2026-09-09'),

    ('Documental Clínica Vista Norte', 'Arriendo de equipos', 'Cámara cine y ópticas',    2100000, '2026-11-16'),
    ('Documental Clínica Vista Norte', 'Catering',            'Catering semana 1',         380000, '2026-11-18'),
    ('Documental Clínica Vista Norte', 'Alimentación',        'Colaciones equipo',         260000, '2026-11-18'),
    ('Documental Clínica Vista Norte', 'Bencina',             'Traslados a locación',      210000, '2026-11-17'),
    ('Documental Clínica Vista Norte', 'Peajes y estacionamiento', 'Peajes y estacionamiento', 45000, '2026-11-17'),

    ('Cobertura aniversario Mar Abierto', 'Arriendo de equipos', 'Reserva de equipos',     650000, '2026-11-19'),

    ('Cápsulas educativas Mar Abierto', 'Arriendo de equipos', 'Cámara y sonido',          900000, '2026-03-23'),
    ('Cápsulas educativas Mar Abierto', 'Bencina',             'Traslados a locación',      60000, '2026-03-24'),
    ('Cápsulas educativas Mar Abierto', 'Alimentación',        'Colaciones equipo',         90000, '2026-03-25')
) AS v(proyecto, categoria, descripcion, monto, fecha)
JOIN proyecto        p ON p.nombre_proyecto = v.proyecto
JOIN categoria_gasto c ON c.nombre = v.categoria;

-- ---------- Documentos ------------------------------------------------
INSERT INTO documento (id_proyecto, tipo, version, estado_aprobacion, fecha, referencia)
SELECT p.id_proyecto, v.tipo, v.version, v.estado, v.fecha::date, v.referencia
FROM (VALUES
    ('Spot institucional Aromos',         'GUION',          1, 'APROBADO',  '2026-05-08', 'Guion v1'),
    ('Spot institucional Aromos',         'PRODUCTO_FINAL', 1, 'APROBADO',  '2026-06-25', 'Spot final 30s'),
    ('Spot institucional Aromos',         'HES',            1, 'APROBADO',  '2026-06-26', 'HES-4500012345'),

    ('Video corporativo Andes Sur',       'GUION',          1, 'APROBADO',  '2026-08-14', 'Guion v1'),

    ('Documental Clínica Vista Norte',    'GUION',          1, 'RECHAZADO', '2026-10-08', 'Guion v1'),
    ('Documental Clínica Vista Norte',    'GUION',          2, 'APROBADO',  '2026-10-14', 'Guion v2'),

    ('Cobertura aniversario Mar Abierto', 'GUION',          1, 'PENDIENTE', '2026-11-18', 'Guion v1'),

    ('Cápsulas educativas Mar Abierto',   'PRODUCTO_FINAL', 1, 'APROBADO',  '2026-05-07', 'Cápsulas 6 piezas'),
    ('Cápsulas educativas Mar Abierto',   'HES',            1, 'APROBADO',  '2026-05-08', 'HES-4500009871')
) AS v(proyecto, tipo, version, estado, fecha, referencia)
JOIN proyecto p ON p.nombre_proyecto = v.proyecto;

-- ---------- Facturas y pagos ------------------------------------------
-- Los triggers (R04) verifican que cada HES esté APROBADO y sea del
-- mismo proyecto que la OC.
INSERT INTO factura (id_oc, id_documento_hes, numero_factura, monto_neto, fecha_emision)
SELECT oc.id_oc, d.id_documento, v.folio, v.neto, v.fecha::date
FROM (VALUES
    ('Spot institucional Aromos',       'F-1001', 8500000, '2026-07-01'),
    ('Cápsulas educativas Mar Abierto', 'F-1002', 6000000, '2026-05-08')
) AS v(proyecto, folio, neto, fecha)
JOIN proyecto     p  ON p.nombre_proyecto = v.proyecto
JOIN cotizacion   c  ON c.id_proyecto = p.id_proyecto AND c.estado = 'APROBADA'
JOIN orden_compra oc ON oc.id_cotizacion = c.id_cotizacion
JOIN documento    d  ON d.id_proyecto = p.id_proyecto AND d.tipo = 'HES';

-- Spot Aromos: total 10.115.000 pagado en dos cuotas (saldo 0).
-- Cápsulas: total 7.140.000, solo anticipo pagado (saldo por cobrar 3.570.000).
INSERT INTO pago (id_factura, tipo, monto, fecha_recepcion)
SELECT f.id_factura, v.tipo, v.monto, v.fecha::date
FROM (VALUES
    ('F-1001', 'ANTICIPO', 5000000, '2026-07-15'),
    ('F-1001', 'FINAL',    5115000, '2026-08-12'),
    ('F-1002', 'ANTICIPO', 3570000, '2026-05-20')
) AS v(folio, tipo, monto, fecha)
JOIN factura f ON f.numero_factura = v.folio;

-- ---------- Indicadores financieros (insumos congelados) ---------------
INSERT INTO indicador_financiero
    (id_proyecto, tipo_calculo, fecha_calculo, ingreso_neto, honorarios_total, costos_fijos, costos_variables)
SELECT p.id_proyecto, v.tipo, v.fecha::date, v.ingreso, v.honorarios, v.fijos, v.variables
FROM (VALUES
    ('Spot institucional Aromos',         'ESTIMADO', '2026-05-02',  8500000, 2500000, 2000000, 300000),
    ('Spot institucional Aromos',         'REAL',     '2026-07-20',  8500000, 2690000, 2050000, 205000),
    ('Video corporativo Andes Sur',       'ESTIMADO', '2026-08-03',  9000000, 3500000, 3500000, 800000),
    ('Documental Clínica Vista Norte',    'ESTIMADO', '2026-09-28', 15000000, 4200000, 4500000, 1200000),
    ('Cobertura aniversario Mar Abierto', 'ESTIMADO', '2026-11-09',  4200000,  800000, 1100000, 400000),
    ('Cápsulas educativas Mar Abierto',   'ESTIMADO', '2026-02-20',  6000000, 1500000, 1000000, 200000),
    ('Cápsulas educativas Mar Abierto',   'REAL',     '2026-06-15',  6000000, 1610000,  900000, 150000)
) AS v(proyecto, tipo, fecha, ingreso, honorarios, fijos, variables)
JOIN proyecto p ON p.nombre_proyecto = v.proyecto;

-- ---------- Usuarios (R16). Hash FALSO de prueba: no usar en producción ---
INSERT INTO usuario (nombre, email, password_hash, rol_acceso) VALUES
    ('Dueño (prueba)',               'dueno@mandala.test',    '$2b$10$HASH.SINTETICO.DE.PRUEBA.0000000000000000000000000000', 'DUENO'),
    ('Administración Finanzas (prueba)', 'finanzas@mandala.test', '$2b$10$HASH.SINTETICO.DE.PRUEBA.1111111111111111111111111111', 'ADMIN_FINANZAS');
