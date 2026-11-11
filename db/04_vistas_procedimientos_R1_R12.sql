-- =====================================================================
-- 04_vistas_procedimientos_R1_R12.sql
-- Requerimientos de información R1 a R12 (6 vistas + 6 procedimientos)
-- Ejecutar DESPUÉS de crear las tablas y cargar los datos.
-- No modifica tablas ni datos: solo crea objetos nuevos.
--
-- Convenciones del modelo actual usadas aquí:
--  * Las fechas están guardadas como VARCHAR 'YYYY-MM-DD'; por eso se
--    convierten con CAST(... AS DATE) al comparar rangos.
--  * "Participante" = PERSONAL vinculado a una expedición mediante
--    PERSONAL_PARTICIPAR.
--  * EVALUACION.EVA_FK_PERSONAL es quien entrega la calificación, por lo
--    que la "evaluación de un participante" es la que ese participante
--    entregó en cada expedición.
--  * "Muestras clasificadas" = MST_TIPO_MUESTRA distinto de 'Sin clasificar'.
-- =====================================================================
USE antartida;
SET NAMES utf8mb4;

DROP VIEW IF EXISTS vw_r2_distribucion_muestras_clasificadas;
DROP VIEW IF EXISTS vw_r3_duracion_vs_evaluacion;
DROP VIEW IF EXISTS vw_r5_ocupacion_bases;
DROP VIEW IF EXISTS vw_r6_tipos_por_base_sector;
DROP VIEW IF EXISTS vw_r7_diversidad_sectores;
DROP VIEW IF EXISTS vw_r8_participantes_frecuentes;

DROP PROCEDURE IF EXISTS sp_r1_bases_mas_expediciones;
DROP PROCEDURE IF EXISTS sp_r4_paises_expediciones_participantes;
DROP PROCEDURE IF EXISTS sp_r9_expediciones_sobre_promedio_base;
DROP PROCEDURE IF EXISTS sp_r10_sectores_sobre_promedio_base;
DROP PROCEDURE IF EXISTS sp_r11_participantes_sobre_promedio;
DROP PROCEDURE IF EXISTS sp_r12_bases_duracion_sobre_promedio;

-- =====================================================================
-- VISTAS
-- =====================================================================

-- R2: ¿Cómo se distribuyen las muestras clasificadas entre biológicas,
--     geológicas y climáticas, por base y sector de recolección?
CREATE VIEW vw_r2_distribucion_muestras_clasificadas AS
SELECT
    b.BS_NOMBRE_BASE                    AS base,
    s.SCT_NOMBRE_SECTOR                 AS sector,
    m.MST_TIPO_MUESTRA                  AS clasificacion,
    COUNT(rm.ID_RECOLECION)             AS recolecciones,
    COUNT(DISTINCT m.ID_MUESTRA)        AS muestras_distintas,
    ROUND(100 * COUNT(rm.ID_RECOLECION)
          / SUM(COUNT(rm.ID_RECOLECION)) OVER (PARTITION BY b.ID_BASE, s.ID_SECTOR), 1)
                                        AS porcentaje_en_sector
FROM REGISTRO_MUESTRA rm
JOIN MUESTRA   m ON m.ID_MUESTRA = rm.RM_FK_MUESTRA
JOIN SECTOR    s ON s.ID_SECTOR = rm.RM_FK_SECTOR AND s.SCT_FK_BASE = rm.RM_FK_BASE
JOIN BASE_PAIS b ON b.ID_BASE = s.SCT_FK_BASE
WHERE m.MST_TIPO_MUESTRA IN ('Biológica', 'Geológica', 'Climática')
GROUP BY b.ID_BASE, b.BS_NOMBRE_BASE, s.ID_SECTOR, s.SCT_NOMBRE_SECTOR, m.MST_TIPO_MUESTRA;

-- R3: ¿Existe relación entre la duración de una expedición y la
--     evaluación promedio entregada por sus participantes?
CREATE VIEW vw_r3_duracion_vs_evaluacion AS
SELECT
    e.ID_EXPEDICION                     AS expedicion,
    b.BS_NOMBRE_BASE                    AS base,
    e.EXP_DURAEXPEDIAS                  AS duracion_dias,
    COUNT(DISTINCT p.ID_PERSONAL)       AS participantes,
    COUNT(ev.ID_EVALUACION)             AS evaluaciones,
    ROUND(AVG(ev.EVA_CALIFICCACION), 2) AS evaluacion_promedio
FROM EXPEDICION e
JOIN BASE_PAIS            b  ON b.ID_BASE = e.EXP_FK_BASE
JOIN PERSONAL_PARTICIPAR  pp ON pp.ID_EXPEDICION = e.ID_EXPEDICION
JOIN PERSONAL             p  ON p.ID_PERSONAL = pp.ID_PERSONAL
LEFT JOIN EVALUACION      ev ON ev.ID_EXPEDICION = pp.ID_EXPEDICION
                            AND ev.EVA_FK_PERSONAL = pp.ID_PERSONAL
GROUP BY e.ID_EXPEDICION, b.BS_NOMBRE_BASE, e.EXP_DURAEXPEDIAS;

-- R5: ¿Qué bases presentan mayor tasa de ocupación de participantes
--     respecto de la capacidad máxima de sus expediciones?
-- NOTA: el modelo actual NO tiene un campo de capacidad máxima. Como
-- referencia se usa la mayor cantidad de participantes registrada en una
-- sola expedición de toda la base de datos. Si se agrega la capacidad al
-- modelo, basta reemplazar x.capacidad_ref por ese campo.
CREATE VIEW vw_r5_ocupacion_bases AS
SELECT
    b.BS_NOMBRE_BASE                    AS base,
    pa.PS_NOMBRE_OFICIAL                AS pais,
    COUNT(*)                            AS expediciones,
    SUM(x.participantes)                AS participantes_totales,
    MAX(x.capacidad_ref)                AS capacidad_referencia,
    ROUND(100 * AVG(x.participantes) / MAX(x.capacidad_ref), 1) AS tasa_ocupacion_pct
FROM (
    SELECT e.ID_EXPEDICION,
           e.EXP_FK_BASE,
           COUNT(pp.ID_PERSONAL)                       AS participantes,
           MAX(COUNT(pp.ID_PERSONAL)) OVER ()          AS capacidad_ref
    FROM EXPEDICION e
    LEFT JOIN PERSONAL_PARTICIPAR pp ON pp.ID_EXPEDICION = e.ID_EXPEDICION
    GROUP BY e.ID_EXPEDICION, e.EXP_FK_BASE
) x
JOIN BASE_PAIS b  ON b.ID_BASE = x.EXP_FK_BASE
JOIN PAIS      pa ON pa.ID_PAIS = b.BS_FK_PAIS
GROUP BY b.ID_BASE, b.BS_NOMBRE_BASE, pa.PS_NOMBRE_OFICIAL
ORDER BY tasa_ocupacion_pct DESC;

-- R6: ¿Qué tipos de muestra concentran la mayor cantidad de
--     recolecciones por base y sector?
CREATE VIEW vw_r6_tipos_por_base_sector AS
SELECT
    b.BS_NOMBRE_BASE                    AS base,
    s.SCT_NOMBRE_SECTOR                 AS sector,
    m.MST_TIPO_MUESTRA                  AS tipo_muestra,
    COUNT(rm.ID_RECOLECION)             AS recolecciones,
    RANK() OVER (PARTITION BY b.ID_BASE, s.ID_SECTOR
                 ORDER BY COUNT(rm.ID_RECOLECION) DESC) AS posicion_en_sector
FROM REGISTRO_MUESTRA rm
JOIN MUESTRA   m ON m.ID_MUESTRA = rm.RM_FK_MUESTRA
JOIN SECTOR    s ON s.ID_SECTOR = rm.RM_FK_SECTOR AND s.SCT_FK_BASE = rm.RM_FK_BASE
JOIN BASE_PAIS b ON b.ID_BASE = s.SCT_FK_BASE
GROUP BY b.ID_BASE, b.BS_NOMBRE_BASE, s.ID_SECTOR, s.SCT_NOMBRE_SECTOR, m.MST_TIPO_MUESTRA;

-- R7: ¿Qué sectores presentan mayor diversidad de muestras recolectadas
--     y qué cantidad total de muestras se obtiene en ellos?
CREATE VIEW vw_r7_diversidad_sectores AS
SELECT
    b.BS_NOMBRE_BASE                    AS base,
    s.SCT_NOMBRE_SECTOR                 AS sector,
    COUNT(DISTINCT m.ID_MUESTRA)        AS muestras_distintas,
    COUNT(DISTINCT m.MST_TIPO_MUESTRA)  AS tipos_distintos,
    COUNT(rm.ID_RECOLECION)             AS recolecciones_totales
FROM BASE_PAIS b
JOIN SECTOR           s  ON s.SCT_FK_BASE = b.ID_BASE
JOIN REGISTRO_MUESTRA rm ON rm.RM_FK_BASE = s.SCT_FK_BASE AND rm.RM_FK_SECTOR = s.ID_SECTOR
JOIN MUESTRA          m  ON m.ID_MUESTRA = rm.RM_FK_MUESTRA
GROUP BY b.ID_BASE, b.BS_NOMBRE_BASE, s.ID_SECTOR, s.SCT_NOMBRE_SECTOR
ORDER BY muestras_distintas DESC, recolecciones_totales DESC;

-- R8: ¿Qué participantes han intervenido en mayor cantidad de
--     expediciones y cuál es su evaluación promedio?
CREATE VIEW vw_r8_participantes_frecuentes AS
SELECT
    p.ID_PERSONAL                       AS id_participante,
    p.PER_NOMBRE                        AS participante,
    COUNT(DISTINCT pp.ID_EXPEDICION)    AS expediciones,
    ROUND(AVG(ev.EVA_CALIFICCACION), 2) AS evaluacion_promedio
FROM PERSONAL p
JOIN PERSONAL_PARTICIPAR pp ON pp.ID_PERSONAL = p.ID_PERSONAL
JOIN EXPEDICION          e  ON e.ID_EXPEDICION = pp.ID_EXPEDICION
LEFT JOIN EVALUACION     ev ON ev.ID_EXPEDICION = pp.ID_EXPEDICION
                           AND ev.EVA_FK_PERSONAL = pp.ID_PERSONAL
GROUP BY p.ID_PERSONAL, p.PER_NOMBRE
HAVING COUNT(DISTINCT pp.ID_EXPEDICION) >= 2
ORDER BY expediciones DESC, evaluacion_promedio DESC;

-- =====================================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =====================================================================
DELIMITER //

-- R1: ¿Qué bases desarrollan la mayor cantidad de expediciones durante
--     un período determinado?
CREATE PROCEDURE sp_r1_bases_mas_expediciones(
    IN p_fecha_inicio  DATE,
    IN p_fecha_termino DATE)
BEGIN
    IF p_fecha_inicio > p_fecha_termino THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la de término';
    END IF;

    SELECT
        pa.PS_NOMBRE_OFICIAL         AS pais,
        b.BS_NOMBRE_BASE             AS base,
        COUNT(e.ID_EXPEDICION)       AS expediciones,
        SUM(e.EXP_DURAEXPEDIAS)      AS dias_totales
    FROM EXPEDICION e
    JOIN BASE_PAIS b  ON b.ID_BASE = e.EXP_FK_BASE
    JOIN PAIS      pa ON pa.ID_PAIS = b.BS_FK_PAIS
    WHERE CAST(e.EXP_FECHA_INICIO AS DATE) BETWEEN p_fecha_inicio AND p_fecha_termino
    GROUP BY pa.ID_PAIS, pa.PS_NOMBRE_OFICIAL, b.ID_BASE, b.BS_NOMBRE_BASE
    ORDER BY expediciones DESC, dias_totales DESC;
END //

-- R4: ¿Qué países concentran la mayor cantidad de expediciones y
--     participantes durante un período determinado?
CREATE PROCEDURE sp_r4_paises_expediciones_participantes(
    IN p_fecha_inicio  DATE,
    IN p_fecha_termino DATE)
BEGIN
    IF p_fecha_inicio > p_fecha_termino THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la de término';
    END IF;

    SELECT
        pa.PS_NOMBRE_OFICIAL                AS pais,
        COUNT(DISTINCT e.ID_EXPEDICION)     AS expediciones,
        COUNT(pp.ID_PERSONAL)               AS participaciones,
        COUNT(DISTINCT pp.ID_PERSONAL)      AS participantes_distintos
    FROM PAIS pa
    JOIN BASE_PAIS b  ON b.BS_FK_PAIS = pa.ID_PAIS
    JOIN EXPEDICION e ON e.EXP_FK_BASE = b.ID_BASE
    JOIN PERSONAL_PARTICIPAR pp ON pp.ID_EXPEDICION = e.ID_EXPEDICION
    WHERE CAST(e.EXP_FECHA_INICIO AS DATE) BETWEEN p_fecha_inicio AND p_fecha_termino
    GROUP BY pa.ID_PAIS, pa.PS_NOMBRE_OFICIAL
    ORDER BY expediciones DESC, participaciones DESC;
END //

-- R9: ¿Qué expediciones superan la duración promedio de las expediciones
--     realizadas en la misma base durante un período determinado?
--     (subconsulta correlacionada)
CREATE PROCEDURE sp_r9_expediciones_sobre_promedio_base(
    IN p_id_base       INT,
    IN p_fecha_inicio  DATE,
    IN p_fecha_termino DATE)
BEGIN
    IF p_fecha_inicio > p_fecha_termino THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la de término';
    END IF;

    SELECT
        e.ID_EXPEDICION          AS expedicion,
        b.BS_NOMBRE_BASE         AS base,
        e.EXP_FECHA_INICIO       AS fecha_inicio,
        e.EXP_DURAEXPEDIAS       AS duracion_dias,
        (SELECT ROUND(AVG(e3.EXP_DURAEXPEDIAS), 2)
           FROM EXPEDICION e3
          WHERE e3.EXP_FK_BASE = e.EXP_FK_BASE
            AND CAST(e3.EXP_FECHA_INICIO AS DATE)
                BETWEEN p_fecha_inicio AND p_fecha_termino) AS duracion_promedio_base,
        COUNT(pp.ID_PERSONAL)    AS participantes
    FROM EXPEDICION e
    JOIN BASE_PAIS b ON b.ID_BASE = e.EXP_FK_BASE
    LEFT JOIN PERSONAL_PARTICIPAR pp ON pp.ID_EXPEDICION = e.ID_EXPEDICION
    WHERE e.EXP_FK_BASE = p_id_base
      AND CAST(e.EXP_FECHA_INICIO AS DATE) BETWEEN p_fecha_inicio AND p_fecha_termino
      AND e.EXP_DURAEXPEDIAS > (
            SELECT AVG(e2.EXP_DURAEXPEDIAS)
              FROM EXPEDICION e2
             WHERE e2.EXP_FK_BASE = e.EXP_FK_BASE
               AND CAST(e2.EXP_FECHA_INICIO AS DATE)
                   BETWEEN p_fecha_inicio AND p_fecha_termino)
    GROUP BY e.ID_EXPEDICION, e.EXP_FK_BASE, b.BS_NOMBRE_BASE,
             e.EXP_FECHA_INICIO, e.EXP_DURAEXPEDIAS
    ORDER BY e.EXP_DURAEXPEDIAS DESC;
END //

-- R10: ¿Qué sectores presentan mayor cantidad de muestras recolectadas
--      que el promedio de los sectores de la misma base?
--      (subconsulta correlacionada)
CREATE PROCEDURE sp_r10_sectores_sobre_promedio_base(IN p_id_base INT)
BEGIN
    SELECT
        b.BS_NOMBRE_BASE            AS base,
        s.SCT_NOMBRE_SECTOR         AS sector,
        COUNT(rm.ID_RECOLECION)     AS muestras_recolectadas,
        (SELECT ROUND(COUNT(rm2.ID_RECOLECION) / COUNT(DISTINCT s2.ID_SECTOR), 2)
           FROM SECTOR s2
           LEFT JOIN REGISTRO_MUESTRA rm2
                  ON rm2.RM_FK_BASE = s2.SCT_FK_BASE AND rm2.RM_FK_SECTOR = s2.ID_SECTOR
          WHERE s2.SCT_FK_BASE = s.SCT_FK_BASE)   AS promedio_sectores_base
    FROM SECTOR s
    JOIN BASE_PAIS b ON b.ID_BASE = s.SCT_FK_BASE
    LEFT JOIN REGISTRO_MUESTRA rm
           ON rm.RM_FK_BASE = s.SCT_FK_BASE AND rm.RM_FK_SECTOR = s.ID_SECTOR
    LEFT JOIN MUESTRA m ON m.ID_MUESTRA = rm.RM_FK_MUESTRA
    WHERE s.SCT_FK_BASE = p_id_base
    GROUP BY s.SCT_FK_BASE, s.ID_SECTOR, b.BS_NOMBRE_BASE, s.SCT_NOMBRE_SECTOR
    HAVING COUNT(rm.ID_RECOLECION) > (
            SELECT COUNT(rm3.ID_RECOLECION) / COUNT(DISTINCT s3.ID_SECTOR)
              FROM SECTOR s3
              LEFT JOIN REGISTRO_MUESTRA rm3
                     ON rm3.RM_FK_BASE = s3.SCT_FK_BASE AND rm3.RM_FK_SECTOR = s3.ID_SECTOR
             WHERE s3.SCT_FK_BASE = s.SCT_FK_BASE)
    ORDER BY muestras_recolectadas DESC;
END //

-- R11: ¿Qué participantes han participado en más expediciones que el
--      promedio y, además, poseen una evaluación promedio superior al
--      promedio general? (subconsulta + agrupación)
CREATE PROCEDURE sp_r11_participantes_sobre_promedio(
    IN p_fecha_inicio  DATE,
    IN p_fecha_termino DATE)
BEGIN
    IF p_fecha_inicio > p_fecha_termino THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la de término';
    END IF;

    SELECT
        p.ID_PERSONAL                       AS id_participante,
        p.PER_NOMBRE                        AS participante,
        COUNT(DISTINCT pp.ID_EXPEDICION)    AS expediciones,
        ROUND(AVG(ev.EVA_CALIFICCACION), 2) AS evaluacion_promedio
    FROM PERSONAL p
    JOIN PERSONAL_PARTICIPAR pp ON pp.ID_PERSONAL = p.ID_PERSONAL
    JOIN EXPEDICION e           ON e.ID_EXPEDICION = pp.ID_EXPEDICION
    LEFT JOIN EVALUACION ev     ON ev.ID_EXPEDICION = pp.ID_EXPEDICION
                               AND ev.EVA_FK_PERSONAL = pp.ID_PERSONAL
    WHERE CAST(e.EXP_FECHA_INICIO AS DATE) BETWEEN p_fecha_inicio AND p_fecha_termino
    GROUP BY p.ID_PERSONAL, p.PER_NOMBRE
    HAVING COUNT(DISTINCT pp.ID_EXPEDICION) > (
               SELECT AVG(t.n)
                 FROM (SELECT COUNT(DISTINCT pp2.ID_EXPEDICION) AS n
                         FROM PERSONAL_PARTICIPAR pp2
                         JOIN EXPEDICION e2 ON e2.ID_EXPEDICION = pp2.ID_EXPEDICION
                        WHERE CAST(e2.EXP_FECHA_INICIO AS DATE)
                              BETWEEN p_fecha_inicio AND p_fecha_termino
                        GROUP BY pp2.ID_PERSONAL) t)
       AND AVG(ev.EVA_CALIFICCACION) > (
               SELECT AVG(ev3.EVA_CALIFICCACION)
                 FROM EVALUACION ev3
                 JOIN EXPEDICION e3 ON e3.ID_EXPEDICION = ev3.ID_EXPEDICION
                WHERE CAST(e3.EXP_FECHA_INICIO AS DATE)
                      BETWEEN p_fecha_inicio AND p_fecha_termino)
    ORDER BY expediciones DESC, evaluacion_promedio DESC;
END //

-- R12: ¿Qué bases presentan una duración promedio de expedición superior
--      al promedio general de las bases durante un período?
--      (subconsulta + agrupación)
CREATE PROCEDURE sp_r12_bases_duracion_sobre_promedio(
    IN p_fecha_inicio  DATE,
    IN p_fecha_termino DATE)
BEGIN
    IF p_fecha_inicio > p_fecha_termino THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la de término';
    END IF;

    SELECT
        pa.PS_NOMBRE_OFICIAL                AS pais,
        b.BS_NOMBRE_BASE                    AS base,
        COUNT(e.ID_EXPEDICION)              AS expediciones,
        ROUND(AVG(e.EXP_DURAEXPEDIAS), 2)   AS duracion_promedio_dias
    FROM EXPEDICION e
    JOIN BASE_PAIS b  ON b.ID_BASE = e.EXP_FK_BASE
    JOIN PAIS      pa ON pa.ID_PAIS = b.BS_FK_PAIS
    WHERE CAST(e.EXP_FECHA_INICIO AS DATE) BETWEEN p_fecha_inicio AND p_fecha_termino
    GROUP BY pa.ID_PAIS, pa.PS_NOMBRE_OFICIAL, b.ID_BASE, b.BS_NOMBRE_BASE
    HAVING AVG(e.EXP_DURAEXPEDIAS) > (
               SELECT AVG(e2.EXP_DURAEXPEDIAS)
                 FROM EXPEDICION e2
                WHERE CAST(e2.EXP_FECHA_INICIO AS DATE)
                      BETWEEN p_fecha_inicio AND p_fecha_termino)
    ORDER BY duracion_promedio_dias DESC;
END //

DELIMITER ;

-- =====================================================================
-- SENTENCIAS DE EJECUCIÓN (para las capturas del informe)
-- =====================================================================
-- CALL sp_r1_bases_mas_expediciones('2023-01-01', '2026-12-31');
-- SELECT * FROM vw_r2_distribucion_muestras_clasificadas;
-- SELECT * FROM vw_r3_duracion_vs_evaluacion;
-- CALL sp_r4_paises_expediciones_participantes('2023-01-01', '2026-12-31');
-- SELECT * FROM vw_r5_ocupacion_bases;
-- SELECT * FROM vw_r6_tipos_por_base_sector;
-- SELECT * FROM vw_r7_diversidad_sectores;
-- SELECT * FROM vw_r8_participantes_frecuentes;
-- CALL sp_r9_expediciones_sobre_promedio_base(1, '2023-01-01', '2026-12-31');
-- CALL sp_r10_sectores_sobre_promedio_base(2);
-- CALL sp_r11_participantes_sobre_promedio('2023-01-01', '2026-12-31');
-- CALL sp_r12_bases_duracion_sobre_promedio('2023-01-01', '2026-12-31');
