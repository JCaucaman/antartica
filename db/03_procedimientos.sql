-- =====================================================================
-- 03_procedimientos.sql  ·  Ejecutar DESPUÉS de 02_datos.sql
-- Procedimientos que la aplicación Python invoca con CALL.
-- =====================================================================
USE antartida;
SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS sp_resumen_expedicion;
DROP PROCEDURE IF EXISTS sp_muestras_por_tipo;
DROP PROCEDURE IF EXISTS sp_recolecciones_por_base;
DROP PROCEDURE IF EXISTS sp_historial_personal;

DELIMITER //

-- 1) Resumen completo de una expedición
CREATE PROCEDURE sp_resumen_expedicion(IN p_id_expedicion INT)
BEGIN
    SELECT
        e.ID_EXPEDICION                       AS expedicion,
        e.EXP_FECHA_INICIO                    AS fecha_inicio,
        e.EXP_DURAEXPEDIAS                    AS dias,
        b.BS_NOMBRE_BASE                      AS base,
        p.PS_NOMBRE_OFICIAL                   AS pais,
        jefe.PER_NOMBRE                       AS a_cargo,
        (SELECT COUNT(*) FROM PERSONAL_PARTICIPAR pp
          WHERE pp.ID_EXPEDICION = e.ID_EXPEDICION)        AS participantes,
        e.EXP_CANTMUESTRAEXPE                 AS muestras_planificadas,
        (SELECT COUNT(*) FROM REGISTRO_MUESTRA rm
          WHERE rm.ID_EXPEDICION = e.ID_EXPEDICION)        AS muestras_registradas,
        (SELECT ROUND(AVG(ev.EVA_CALIFICCACION), 2) FROM EVALUACION ev
          WHERE ev.ID_EXPEDICION = e.ID_EXPEDICION)        AS promedio_evaluacion
    FROM EXPEDICION e
    JOIN BASE_PAIS b   ON b.ID_BASE = e.EXP_FK_BASE
    JOIN PAIS p        ON p.ID_PAIS = b.BS_FK_PAIS
    JOIN PERSONAL jefe ON jefe.ID_PERSONAL = e.EXP_FK_PERSONAL_ACARGO
    WHERE e.ID_EXPEDICION = p_id_expedicion;
END //

-- 2) Cantidad de muestras y recolecciones por tipo
CREATE PROCEDURE sp_muestras_por_tipo()
BEGIN
    SELECT
        m.MST_TIPO_MUESTRA                AS tipo,
        COUNT(DISTINCT m.ID_MUESTRA)      AS muestras,
        COUNT(rm.ID_RECOLECION)           AS recolecciones
    FROM MUESTRA m
    LEFT JOIN REGISTRO_MUESTRA rm ON rm.RM_FK_MUESTRA = m.ID_MUESTRA
    GROUP BY m.MST_TIPO_MUESTRA
    ORDER BY recolecciones DESC;
END //

-- 3) Recolecciones por base y sector
CREATE PROCEDURE sp_recolecciones_por_base()
BEGIN
    SELECT
        b.BS_NOMBRE_BASE        AS base,
        s.SCT_NOMBRE_SECTOR     AS sector,
        s.SCT_NIVEL_ACCESO      AS acceso,
        COUNT(rm.ID_RECOLECION) AS recolecciones
    FROM SECTOR s
    JOIN BASE_PAIS b ON b.ID_BASE = s.SCT_FK_BASE
    LEFT JOIN REGISTRO_MUESTRA rm
           ON rm.RM_FK_BASE = s.SCT_FK_BASE AND rm.RM_FK_SECTOR = s.ID_SECTOR
    GROUP BY b.BS_NOMBRE_BASE, s.SCT_NOMBRE_SECTOR, s.SCT_NIVEL_ACCESO
    ORDER BY recolecciones DESC, base;
END //

-- 4) Historial de un integrante del personal
CREATE PROCEDURE sp_historial_personal(IN p_id_personal INT)
BEGIN
    SELECT
        pp.ID_EXPEDICION              AS expedicion,
        b.BS_NOMBRE_BASE              AS base,
        pp.PP_FUNCION_DESEMPENNADA    AS funcion,
        pp.PP_ESTADO                  AS estado,
        ev.EVA_CALIFICCACION          AS calificacion_entregada,
        (SELECT COUNT(*) FROM REGISTRO_MUESTRA rm
          WHERE rm.ID_EXPEDICION = pp.ID_EXPEDICION
            AND rm.RM_FK_PERSONAL_RESPONTABLE = pp.ID_PERSONAL) AS muestras_recolectadas
    FROM PERSONAL_PARTICIPAR pp
    JOIN EXPEDICION e ON e.ID_EXPEDICION = pp.ID_EXPEDICION
    JOIN BASE_PAIS b  ON b.ID_BASE = e.EXP_FK_BASE
    LEFT JOIN EVALUACION ev
           ON ev.ID_EXPEDICION = pp.ID_EXPEDICION AND ev.EVA_FK_PERSONAL = pp.ID_PERSONAL
    WHERE pp.ID_PERSONAL = p_id_personal
    ORDER BY pp.ID_EXPEDICION;
END //

DELIMITER ;

-- Pruebas en Workbench:
-- CALL sp_resumen_expedicion(1);
-- CALL sp_muestras_por_tipo();
-- CALL sp_recolecciones_por_base();
-- CALL sp_historial_personal(1);
