-- =====================================================================
-- DATOS DE PRUEBA - Expediciones científicas antárticas
-- Orden de inserción respeta las claves foráneas.
-- Equivalencias con el contexto: B01=1, S01=1, P01=1, M01=1, EXP01=1,
-- REC01=1, EV01=1 (y así sucesivamente).
-- =====================================================================

-- ---------------------------------------------------------------------
-- PAIS (10)
-- ---------------------------------------------------------------------
INSERT INTO PAIS (ID_PAIS, PS_NOMBRE_OFICIAL, PS_PRESUPUESTO_ANUAL, PS_ORGANISMO_RESPONASABLE) VALUES
(1,  'República de Chile',            45000000,  'Instituto Antártico Chileno'),
(2,  'República Argentina',           52000000,  'Dirección Nacional del Antártico'),
(3,  'Reino Unido',                   98000000,  'British Antarctic Survey'),
(4,  'Estados Unidos de América',     310000000, 'US Antarctic Program'),
(5,  'Federación de Rusia',           87000000,  'Instituto de Investigación Ártico y Antártico'),
(6,  'República Popular China',       120000000, 'Administración Ártica y Antártica China'),
(7,  'Mancomunidad de Australia',     105000000, 'Australian Antarctic Division'),
(8,  'Reino de Noruega',              76000000,  'Instituto Polar Noruego'),
(9,  'República Francesa',            92000000,  'Instituto Polar Paul-Émile Victor'),
(10, 'Japón',                         110000000, 'Instituto Nacional de Investigación Polar');

-- ---------------------------------------------------------------------
-- BASE_PAIS (10)
-- ---------------------------------------------------------------------
INSERT INTO BASE_PAIS (ID_BASE, BS_FECHA_INSTALACION, BS_UBICACION, BS_NOMBRE_BASE, BS_FK_PAIS) VALUES
(1,  '2005-11-20', 'Península Antártica',     'Base Aurora',        1),
(2,  '1998-01-15', 'Polo Sur Geográfico',     'Base Polar Sur',     4),
(3,  '2010-12-03', 'Isla Rey Jorge',          'Base Horizonte',     2),
(4,  '2001-02-10', 'Tierra de la Reina Maud', 'Base Glaciar Azul',  8),
(5,  '1995-12-12', 'Costa de Enderby',        'Base Ventisca',      5),
(6,  '2014-01-25', 'Tierra de Wilkes',        'Base Cristal',       6),
(7,  '2003-11-30', 'Tierra de Victoria',      'Base Austral',       7),
(8,  '2008-12-18', 'Isla Decepción',          'Base Albatros',      3),
(9,  '2005-12-20', 'Tierra Adelia',           'Base Concordia',     9),
(10, '1983-11-15', 'Bahía Lützow-Holm',       'Base Shirase',       10);

-- ---------------------------------------------------------------------
-- SECTOR (11) - PK compuesta (ID_SECTOR, SCT_FK_BASE)
-- Columnas: ID_SECTOR, SCT_FK_BASE, NIVEL_AISLAMIENTO, SUPERFICIE,
--           NOMBRE_SECTOR, NIVEL_ACCESO, CONDICIONES_CLI
-- ---------------------------------------------------------------------
INSERT INTO SECTOR (ID_SECTOR, SCT_FK_BASE, SCT_NIVEL_AISLAMIENTO, SCT_SUPERFICIE, SCT_NOMBRE_SECTOR, SCT_NIVEL_ACCESO, SCT_CONDICIONES_CLI) VALUES
(1, 1, 'Alto',    1200, 'Glaciar Este',      'Restringido', 'Frío extremo, vientos fuertes'),
(2, 1, 'Medio',   950,  'Costa Norte',       'Controlado',  'Frío moderado, nevadas'),
(1, 2, 'Extremo', 2100, 'Meseta Central',    'Restringido', 'Frío extremo, baja humedad'),
(2, 2, 'Alto',    1500, 'Bahía Sur',         'Controlado',  'Vientos catabáticos'),
(1, 3, 'Medio',   800,  'Valle Blanco',      'Libre',       'Frío moderado, cielo despejado'),
(2, 3, 'Alto',    1100, 'Península Oeste',   'Controlado',  'Ventiscas frecuentes'),
(1, 4, 'Alto',    1750, 'Cordillera Norte',  'Restringido', 'Frío extremo, nieblas'),
(2, 4, 'Medio',   900,  'Llanura Helada',    'Libre',       'Frío moderado, viento constante'),
(1, 5, 'Extremo', 2300, 'Lago Subglacial',   'Restringido', 'Frío extremo, hielo profundo'),
(2, 5, 'Alto',    1300, 'Cañón Gélido',      'Controlado',  'Temperaturas bajo -40 C'),
(1, 6, 'Medio',   1000, 'Campo de Hielo',    'Controlado',  'Frío moderado, nevadas leves');

-- ---------------------------------------------------------------------
-- PERSONAL (10)
-- Roles: PER_CIENTIFICO, PER_TECNICO, PER_ADMIN, PER_COORDINADOR (1 = sí, 0 = no)
-- ---------------------------------------------------------------------
INSERT INTO PERSONAL (ID_PERSONAL, PER_NOMBRE, PER_CIENTIFICO, PER_TECNICO, PER_ADMIN, PER_COORDINADOR) VALUES
(1,  'Elena Rivas',     1, 0, 0, 0),
(2,  'Carlos Díaz',     0, 1, 0, 0),
(3,  'Marcela León',    0, 0, 0, 1),
(4,  'Iván Soto',       1, 0, 0, 0),
(5,  'Lucía Mora',      0, 0, 1, 0),
(6,  'Pablo Núñez',     0, 0, 0, 1),
(7,  'Andrea Fuentes',  0, 0, 0, 1),
(8,  'Tomás Vega',      0, 1, 0, 0),
(9,  'Camila Rojas',    1, 0, 0, 0),
(10, 'Jorge Paredes',   0, 0, 1, 0);

-- ---------------------------------------------------------------------
-- USUARIO (10) - PK compuesta (N_ACCESO_USER, USER_FK_PERSONAL)
-- Nota: las contraseñas son de ejemplo; en un sistema real deben guardarse hasheadas.
-- ---------------------------------------------------------------------
INSERT INTO USUARIO (N_ACCESO_USER, USER_NOMBRE_USUARIO, USER_CONSTRASENNA, USER_ROL, USER_FK_PERSONAL) VALUES
('ACC001', 'erivas',    'Pass#Elena01',   'Científico',    1),
('ACC002', 'cdiaz',     'Pass#Carlos02',  'Técnico',       2),
('ACC003', 'mleon',     'Pass#Marcela03', 'Coordinador',   3),
('ACC004', 'isoto',     'Pass#Ivan04',    'Científico',    4),
('ACC005', 'lmora',     'Pass#Lucia05',   'Administrador', 5),
('ACC006', 'pnunez',    'Pass#Pablo06',   'Coordinador',   6),
('ACC007', 'afuentes',  'Pass#Andrea07',  'Coordinador',   7),
('ACC008', 'tvega',     'Pass#Tomas08',   'Técnico',       8),
('ACC009', 'crojas',    'Pass#Camila09',  'Científico',    9),
('ACC010', 'jparedes',  'Pass#Jorge10',   'Administrador', 10);

-- ---------------------------------------------------------------------
-- EXPEDICION (10)
-- Columnas: ID, FECHA_INICIO, DURACION_DIAS, CANT_MUESTRAS, FK_BASE, FK_PERSONAL_ACARGO
-- ---------------------------------------------------------------------
INSERT INTO EXPEDICION (ID_EXPEDICION, EXP_FECHA_INICIO, EXP_DURAEXPEDIAS, EXP_CANTMUESTRAEXPE, EXP_FK_BASE, EXP_FK_PERSONAL_ACARGO) VALUES
(1,  '2023-01-10', 7,  8,  1, 3),
(2,  '2023-02-05', 8,  9,  2, 3),
(3,  '2024-03-12', 9,  10, 3, 3),
(4,  '2024-04-08', 10, 11, 1, 6),
(5,  '2024-05-15', 11, 12, 2, 7),
(6,  '2024-06-03', 7,  13, 3, 3),
(7,  '2025-07-10', 8,  8,  1, 7),
(8,  '2025-08-12', 9,  9,  2, 3),
(9,  '2025-09-09', 10, 10, 3, 6),
(10, '2026-10-14', 11, 11, 1, 7);

-- ---------------------------------------------------------------------
-- PERSONAL_PARTICIPAR (40: 4 participantes por expedición)
-- Funciones: P1 y P4 Científico, P2 Técnico de terreno,
--            P3 Coordinador logístico, P5 Administrador de base
-- ---------------------------------------------------------------------
INSERT INTO PERSONAL_PARTICIPAR (ID_EXPEDICION, ID_PERSONAL, PP_ESTADO, PP_FECHA_INCORPORACION, PP_FUNCION_DESEMPENNADA, PP_OBSERVACIONES) VALUES
-- EXP01
(1, 1, 'Finalizado', '2024-01-10', 'Científico',            'Sin novedades'),
(1, 2, 'Finalizado', '2024-01-10', 'Técnico de terreno',    'Excelente desempeño'),
(1, 3, 'Finalizado', '2024-01-10', 'Coordinador logístico', 'Requiere apoyo logístico'),
(1, 4, 'Finalizado', '2024-01-10', 'Científico',            'Recolección destacada'),
-- EXP02
(2, 2, 'Finalizado', '2024-02-05', 'Técnico de terreno',    'Sin novedades'),
(2, 3, 'Finalizado', '2024-02-05', 'Coordinador logístico', 'Excelente desempeño'),
(2, 4, 'Finalizado', '2024-02-05', 'Científico',            'Requiere apoyo logístico'),
(2, 5, 'Finalizado', '2024-02-05', 'Administrador de base', 'Recolección destacada'),
-- EXP03
(3, 3, 'Finalizado', '2024-03-12', 'Coordinador logístico', 'Sin novedades'),
(3, 4, 'Finalizado', '2024-03-12', 'Científico',            'Excelente desempeño'),
(3, 5, 'Finalizado', '2024-03-12', 'Administrador de base', 'Requiere apoyo logístico'),
(3, 1, 'Finalizado', '2024-03-12', 'Científico',            'Recolección destacada'),
-- EXP04
(4, 4, 'Finalizado', '2024-04-08', 'Científico',            'Sin novedades'),
(4, 5, 'Finalizado', '2024-04-08', 'Administrador de base', 'Excelente desempeño'),
(4, 1, 'Finalizado', '2024-04-08', 'Científico',            'Requiere apoyo logístico'),
(4, 2, 'Finalizado', '2024-04-08', 'Técnico de terreno',    'Recolección destacada'),
-- EXP05
(5, 5, 'Finalizado', '2024-05-15', 'Administrador de base', 'Sin novedades'),
(5, 1, 'Finalizado', '2024-05-15', 'Científico',            'Excelente desempeño'),
(5, 2, 'Finalizado', '2024-05-15', 'Técnico de terreno',    'Requiere apoyo logístico'),
(5, 3, 'Finalizado', '2024-05-15', 'Coordinador logístico', 'Recolección destacada'),
-- EXP06
(6, 1, 'Finalizado', '2024-06-03', 'Científico',            'Sin novedades'),
(6, 2, 'Finalizado', '2024-06-03', 'Técnico de terreno',    'Excelente desempeño'),
(6, 3, 'Finalizado', '2024-06-03', 'Coordinador logístico', 'Requiere apoyo logístico'),
(6, 4, 'Finalizado', '2024-06-03', 'Científico',            'Recolección destacada'),
-- EXP07
(7, 2, 'Finalizado', '2024-07-10', 'Técnico de terreno',    'Sin novedades'),
(7, 3, 'Finalizado', '2024-07-10', 'Coordinador logístico', 'Excelente desempeño'),
(7, 4, 'Finalizado', '2024-07-10', 'Científico',            'Requiere apoyo logístico'),
(7, 5, 'Finalizado', '2024-07-10', 'Administrador de base', 'Recolección destacada'),
-- EXP08
(8, 3, 'Finalizado', '2024-08-12', 'Coordinador logístico', 'Sin novedades'),
(8, 4, 'Finalizado', '2024-08-12', 'Científico',            'Excelente desempeño'),
(8, 5, 'Finalizado', '2024-08-12', 'Administrador de base', 'Requiere apoyo logístico'),
(8, 1, 'Finalizado', '2024-08-12', 'Científico',            'Recolección destacada'),
-- EXP09
(9, 4, 'Finalizado', '2024-09-09', 'Científico',            'Sin novedades'),
(9, 5, 'Finalizado', '2024-09-09', 'Administrador de base', 'Excelente desempeño'),
(9, 1, 'Finalizado', '2024-09-09', 'Científico',            'Requiere apoyo logístico'),
(9, 2, 'Finalizado', '2024-09-09', 'Técnico de terreno',    'Recolección destacada'),
-- EXP10
(10, 5, 'Finalizado', '2024-10-14', 'Administrador de base', 'Sin novedades'),
(10, 1, 'Finalizado', '2024-10-14', 'Científico',            'Excelente desempeño'),
(10, 2, 'Finalizado', '2024-10-14', 'Técnico de terreno',    'Requiere apoyo logístico'),
(10, 3, 'Finalizado', '2024-10-14', 'Coordinador logístico', 'Recolección destacada');

-- ---------------------------------------------------------------------
-- MUESTRA (10)
-- M01 Biológica, M02 Geológica, M03 Climática, M04 Biológica (según contexto)
-- M10 queda "Sin clasificar" (muestra temporalmente sin clasificación)
-- ---------------------------------------------------------------------
INSERT INTO MUESTRA (ID_MUESTRA, MST_ESTADO_CONSERVACION, MST_DESCRIPCION, MST_TIPO_MUESTRA, MST_FK_PERSONAL) VALUES
(1,  'Congelada',        'Liquen de roca costera',   'Biológica',     1),
(2,  'Estable',          'Basalto volcánico',        'Geológica',     2),
(3,  'Refrigerada',      'Núcleo de hielo de 2 m',   'Climática',     3),
(4,  'Congelada',        'Muestra de krill',         'Biológica',     4),
(5,  'Estable',          'Granito fracturado',       'Geológica',     5),
(6,  'Refrigerada',      'Aire atrapado en hielo',   'Climática',     9),
(7,  'Congelada',        'Alga de lago subglacial',  'Biológica',     9),
(8,  'Estable',          'Sedimento marino',         'Geológica',     8),
(9,  'Refrigerada',      'Nieve estratificada',      'Climática',     4),
(10, 'Deterioro leve',   'Tejido sin identificar',   'Sin clasificar', 6);

-- ---------------------------------------------------------------------
-- EVALUACION (40) - PK compuesta (ID_EVALUACION, ID_EXPEDICION)
-- Columnas: ID_EVALUACION, ID_EXPEDICION, CALIFICACION, FECHA, FK_PERSONAL
-- Cada evaluación la realiza el participante en el mismo orden que PERSONAL_PARTICIPAR.
-- ---------------------------------------------------------------------
INSERT INTO EVALUACION (ID_EVALUACION, ID_EXPEDICION, EVA_CALIFICCACION, EVA_FECHA_EVALUACION, EVA_FK_PERSONAL) VALUES
-- EXP01
(1, 1, 3, '2024-01-18', 1), (2, 1, 4, '2024-01-18', 2), (3, 1, 5, '2024-01-18', 3), (4, 1, 3, '2024-01-18', 4),
-- EXP02
(1, 2, 4, '2024-02-14', 2), (2, 2, 5, '2024-02-14', 3), (3, 2, 3, '2024-02-14', 4), (4, 2, 4, '2024-02-14', 5),
-- EXP03
(1, 3, 5, '2024-03-22', 3), (2, 3, 3, '2024-03-22', 4), (3, 3, 4, '2024-03-22', 5), (4, 3, 5, '2024-03-22', 1),
-- EXP04
(1, 4, 3, '2024-04-19', 4), (2, 4, 4, '2024-04-19', 5), (3, 4, 5, '2024-04-19', 1), (4, 4, 3, '2024-04-19', 2),
-- EXP05
(1, 5, 4, '2024-05-27', 5), (2, 5, 5, '2024-05-27', 1), (3, 5, 3, '2024-05-27', 2), (4, 5, 4, '2024-05-27', 3),
-- EXP06
(1, 6, 5, '2024-06-11', 1), (2, 6, 3, '2024-06-11', 2), (3, 6, 4, '2024-06-11', 3), (4, 6, 5, '2024-06-11', 4),
-- EXP07
(1, 7, 3, '2024-07-19', 2), (2, 7, 4, '2024-07-19', 3), (3, 7, 5, '2024-07-19', 4), (4, 7, 3, '2024-07-19', 5),
-- EXP08
(1, 8, 4, '2024-08-22', 3), (2, 8, 5, '2024-08-22', 4), (3, 8, 3, '2024-08-22', 5), (4, 8, 4, '2024-08-22', 1),
-- EXP09
(1, 9, 5, '2024-09-20', 4), (2, 9, 3, '2024-09-20', 5), (3, 9, 4, '2024-09-20', 1), (4, 9, 5, '2024-09-20', 2),
-- EXP10
(1, 10, 3, '2024-10-26', 5), (2, 10, 4, '2024-10-26', 1), (3, 10, 5, '2024-10-26', 2), (4, 10, 3, '2024-10-26', 3);

-- ---------------------------------------------------------------------
-- REGISTRO_MUESTRA (40) - PK compuesta (ID_RECOLECION, ID_EXPEDICION)
-- Columnas: ID_RECOLECION, ID_EXPEDICION, FECHA, FK_PERSONAL_RESPONSABLE,
--           FK_BASE, FK_SECTOR, FK_MUESTRA
-- Base/sector por expedición: 1->(B1,S1) 2->(B2,S2) 3->(B3,S1) 4->(B1,S2) 5->(B2,S1)
--                             6->(B3,S2) 7->(B1,S1) 8->(B2,S2) 9->(B3,S1) 10->(B1,S2)
-- ---------------------------------------------------------------------
INSERT INTO REGISTRO_MUESTRA (ID_RECOLECION, ID_EXPEDICION, RM_FECHA_RECOLECCION, RM_FK_PERSONAL_RESPONTABLE, RM_FK_BASE, RM_FK_SECTOR, RM_FK_MUESTRA) VALUES
-- EXP01 (Base 1, Sector 1)
(1, 1, '2024-01-11', 1, 1, 1, 1), (2, 1, '2024-01-12', 2, 1, 1, 2), (3, 1, '2024-01-13', 3, 1, 1, 3), (4, 1, '2024-01-14', 4, 1, 1, 4),
-- EXP02 (Base 2, Sector 2)
(1, 2, '2024-02-06', 2, 2, 2, 2), (2, 2, '2024-02-07', 3, 2, 2, 3), (3, 2, '2024-02-08', 4, 2, 2, 4), (4, 2, '2024-02-09', 5, 2, 2, 1),
-- EXP03 (Base 3, Sector 1)
(1, 3, '2024-03-13', 3, 3, 1, 3), (2, 3, '2024-03-14', 4, 3, 1, 4), (3, 3, '2024-03-15', 5, 3, 1, 1), (4, 3, '2024-03-16', 1, 3, 1, 2),
-- EXP04 (Base 1, Sector 2)
(1, 4, '2024-04-09', 4, 1, 2, 4), (2, 4, '2024-04-10', 5, 1, 2, 1), (3, 4, '2024-04-11', 1, 1, 2, 2), (4, 4, '2024-04-12', 2, 1, 2, 3),
-- EXP05 (Base 2, Sector 1)
(1, 5, '2024-05-16', 5, 2, 1, 1), (2, 5, '2024-05-17', 1, 2, 1, 2), (3, 5, '2024-05-18', 2, 2, 1, 3), (4, 5, '2024-05-19', 3, 2, 1, 4),
-- EXP06 (Base 3, Sector 2)
(1, 6, '2024-06-04', 1, 3, 2, 2), (2, 6, '2024-06-05', 2, 3, 2, 3), (3, 6, '2024-06-06', 3, 3, 2, 4), (4, 6, '2024-06-07', 4, 3, 2, 1),
-- EXP07 (Base 1, Sector 1)
(1, 7, '2024-07-11', 2, 1, 1, 3), (2, 7, '2024-07-12', 3, 1, 1, 4), (3, 7, '2024-07-13', 4, 1, 1, 1), (4, 7, '2024-07-14', 5, 1, 1, 2),
-- EXP08 (Base 2, Sector 2)
(1, 8, '2024-08-13', 3, 2, 2, 4), (2, 8, '2024-08-14', 4, 2, 2, 1), (3, 8, '2024-08-15', 5, 2, 2, 2), (4, 8, '2024-08-16', 1, 2, 2, 3),
-- EXP09 (Base 3, Sector 1)
(1, 9, '2024-09-10', 4, 3, 1, 1), (2, 9, '2024-09-11', 5, 3, 1, 2), (3, 9, '2024-09-12', 1, 3, 1, 3), (4, 9, '2024-09-13', 2, 3, 1, 4),
-- EXP10 (Base 1, Sector 2)
(1, 10, '2024-10-15', 5, 1, 2, 2), (2, 10, '2024-10-16', 1, 1, 2, 3), (3, 10, '2024-10-17', 2, 1, 2, 4), (4, 10, '2024-10-18', 3, 1, 2, 1);
