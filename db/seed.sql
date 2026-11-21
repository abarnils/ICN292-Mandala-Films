USE mandalafilms;

INSERT INTO trabajadores (nombre_trabajador, rut) VALUES
('Camila Rojas', '17482910-3'),
('Mateo Sepúlveda', '16938471-K'),
('Javiera Soto', '18204955-2'),
('Sebastián Contreras', '15847291-8'),
('Valentina Núñez', '19048273-6'),
('Diego Morales', '14739204-5'),
('Fernanda Espinoza', '18651029-1'),
('Tomás Herrera', '17192834-9'),
('Catalina Fuentes', '19384712-4'),
('Nicolás Castro', '16294817-7');

INSERT INTO proyectos (
nombre_proyecto, ejecutivo, fecha_inicio, fecha_termino, presupuesto,
contacto, visita, guion, grabacion, locucion, edicion_offline,
animacion, edicion_online, color, entrega, oc, factura, pago
) VALUES
('Campaña Bebida Botánica', 'Andrés Valdés', '2026-11-10', '2026-12-15',
4500000.00, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
FALSE, FALSE, FALSE, FALSE),

('Documental Ruta del Sur', 'Paula Mardones', '2026-09-01', '2026-11-30',
8200000.00, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE,
FALSE, TRUE, TRUE, FALSE),

('Spot Lanzamiento EcoTech', 'Andrés Valdés', '2026-07-15', '2026-09-20',
6100000.00, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
TRUE, TRUE, TRUE, TRUE);

INSERT INTO honorarios (
id_proyecto, id_trabajador, rol, honorario_bruto, boleta, pagado
) VALUES
(1, 2, 'camarografo', 480000.00, TRUE, FALSE),
(1, 5, 'asistente', 320000.00, FALSE, FALSE),
(1, 8, 'editor', 610000.00, FALSE, FALSE),
(2, 1, 'camarografo', 1450000.00, TRUE, TRUE),
(2, 3, 'editor', 890000.00, TRUE, FALSE),
(2, 4, 'sonidista', 740000.00, TRUE, TRUE),
(2, 7, 'asistente', 530000.00, FALSE, FALSE),
(2, 10, 'colorista', 680000.00, TRUE, FALSE),
(3, 1, 'camarografo', 1200000.00, TRUE, TRUE),
(3, 6, 'editor', 950000.00, TRUE, TRUE),
(3, 8, 'animador', 560000.00, TRUE, TRUE),
(3, 9, 'asistente', 790000.00, TRUE, TRUE);

INSERT INTO costos_fijos (nombre_costo, costo) VALUES
('arriendo', 750000.00),
('sueldo', 1200000.00),
('creditos', 400000.00),
('telefonia', 50000.00);
