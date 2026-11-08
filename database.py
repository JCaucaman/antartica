import matplotlib.pyplot as plt
import pymysql.cursors

from validar import fechas, integer, string, texto_valido

TIPOS_MUESTRA = ["Biológica", "Geológica", "Climática", "Sin clasificar"]
ESTADOS_CONSERVACION = ["Congelada", "Refrigerada", "Estable", "Deterioro leve", "Deteriorada"]

def conectar():
    return pymysql.connect(
        host="localhost",
        user="root",
        password="",
        db="antartida",
        cursorclass=pymysql.cursors.DictCursor,
    )

def imprimir_tabla(filas):
    if not filas:
        print("  (sin resultados)")
        return
    columnas = list(filas[0].keys())
    anchos = {c: max(len(str(c)), *(len(str(f[c])) for f in filas)) for c in columnas}
    print("  " + " | ".join(str(c).ljust(anchos[c]) for c in columnas))
    print("  " + "-+-".join("-" * anchos[c] for c in columnas))
    for f in filas:
        print("  " + " | ".join(str(f[c]).ljust(anchos[c]) for c in columnas))

def pedir_entero(mensaje, nombre):
    """Pide un número entero y repite la pregunta hasta que sea válido."""
    valor = input(mensaje)

    while not integer(valor):
        print(f"Error: {nombre} no es un número entero.")
        valor = input(mensaje)

    return int(valor)

def pedir_fecha(mensaje, nombre):
    """Pide una fecha YYYY-MM-DD y repite la pregunta hasta que sea válida."""
    valor = input(mensaje)

    while not fechas(valor):
        print(f"Error: {nombre} no es válida.")
        valor = input(mensaje)

    return valor

def elegir_opcion(mensaje, opciones):
    """Muestra una lista numerada y devuelve el texto de la opción elegida."""
    for numero, opcion in enumerate(opciones, start=1):
        print(f"  {numero}. {opcion}")

    eleccion = pedir_entero(mensaje, "La opción")

    while not 1 <= eleccion <= len(opciones):
        print("Error: La opción está fuera de rango.")
        eleccion = pedir_entero(mensaje, "La opción")

    return opciones[eleccion - 1]

def listar_expediciones() -> list:
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("SELECT * FROM expedicion;")
            datos = cursor.fetchall()

        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()


def registrar_expedicion():
    id_expedicion = input("Ingrese el ID de la expedición: ")

    while not integer(id_expedicion):
        print("Error: El ID de la expedición no es un número entero.")
        id_expedicion = input("Ingrese el ID de la expedición: ")

    exp_fecha_inicio = input("Ingrese la fecha de inicio de la expedición (YYYY-MM-DD): ")

    while not fechas(exp_fecha_inicio):
        print("Error: La fecha de inicio no es válida.")
        exp_fecha_inicio = input("Ingrese la fecha de inicio de la expedición (YYYY-MM-DD): ")

    exp_duracion_expedicion = input("Ingrese la duración de la expedición (en días): ")

    while not integer(exp_duracion_expedicion):
        print("Error: La duración de la expedición no es un número entero.")
        exp_duracion_expedicion = input("Ingrese la duración de la expedición (en días): ")

    exp_cantidad_muestra_expedicion = input("Ingrese la cantidad de muestras de la expedición: ")

    while not integer(exp_cantidad_muestra_expedicion):
        print("Error: La cantidad de muestras no es un número entero.")
        exp_cantidad_muestra_expedicion = input("Ingrese la cantidad de muestras de la expedición: ")

    exp_fk_base = input("Ingrese el ID de la base: ")

    while not integer(exp_fk_base):
        print("Error: El ID de la base no es un número entero.")
        exp_fk_base = input("Ingrese el ID de la base: ")

    exp_fk_personal_acargo = input("Ingrese el ID del personal a cargo: ")

    while not integer(exp_fk_personal_acargo):
        print("Error: El ID del personal a cargo no es un número entero.")
        exp_fk_personal_acargo = input("Ingrese el ID del personal a cargo: ")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                """INSERT INTO expedicion (id_expedicion, exp_fecha_inicio, EXP_DURAEXPEDIAS, EXP_CANTMUESTRAEXPE, exp_fk_base, exp_fk_personal_acargo) VALUES 
                (%s, %s, %s, %s, %s, %s)""",
                (
                    id_expedicion,
                    exp_fecha_inicio,
                    exp_duracion_expedicion,
                    exp_cantidad_muestra_expedicion,
                    exp_fk_base,
                    exp_fk_personal_acargo,
                ),
            )
            conexion.commit()
            print("Expedición registrada exitosamente.")

            return {
                "id_expedicion": id_expedicion,
                "exp_fecha_inicio": exp_fecha_inicio,
                "exp_duracion_expedicion": exp_duracion_expedicion,
                "exp_cantidad_muestra_expedicion": exp_cantidad_muestra_expedicion,
                "exp_fk_base": exp_fk_base,
                "exp_fk_personal_acargo": exp_fk_personal_acargo,
            }
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()


def consultar_participantes_expedicion():
    id_expedicion = input("Ingrese el ID de la expedición: ")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                """
                SELECT p.ID_PERSONAL, PER_NOMBRE, PP_FECHA_INCORPORACION, PP_FUNCION_DESEMPENNADA, PP_OBSERVACIONES
                FROM personal_participar AS pp INNER JOIN personal AS p ON pp.id_personal = p.id_personal 
                WHERE pp.id_expedicion = %s""",
                (id_expedicion,),
            )

            datos = cursor.fetchall()

        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()

def delete_expedicion():
    conexion = conectar()
    try:

        id_expedicion = input("Ingrese el ID de la expedición a eliminar: ")

        with conexion.cursor() as cursor:
            cursor.execute("DELETE FROM expedicion WHERE id_expedicion = %s", (id_expedicion,))
            conexion.commit()
            print(f"Expedición con ID {id_expedicion} eliminada exitosamente.")
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()

def graficar_expediciones_por_año():
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                "SELECT YEAR(exp_fecha_inicio) AS año, COUNT(*) AS cantidad_expediciones FROM expedicion GROUP BY YEAR(exp_fecha_inicio);"
            )
            datos = cursor.fetchall()

        # Graficar los datos
        años = [str(fila["año"]) for fila in datos]
        cantidades = [int(fila["cantidad_expediciones"]) for fila in datos]
        plt.bar(años, cantidades)
        plt.xlabel("Año")
        plt.ylabel("Cantidad de Expediciones")
        plt.title("Cantidad de Expediciones por Año")
        plt.show()

        return datos
    finally:
        conexion.close()


# =====================================================================
# MUESTRAS (SELECT / INSERT / UPDATE / DELETE)
# =====================================================================

def listar_muestras() -> list:
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                """
                SELECT m.ID_MUESTRA AS id, m.MST_TIPO_MUESTRA AS tipo, m.MST_DESCRIPCION AS descripcion,
                       m.MST_ESTADO_CONSERVACION AS estado, p.PER_NOMBRE AS responsable
                FROM MUESTRA AS m LEFT JOIN PERSONAL AS p ON p.ID_PERSONAL = m.MST_FK_PERSONAL
                ORDER BY m.ID_MUESTRA"""
            )
            datos = cursor.fetchall()

        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()


def registrar_muestra():
    mst_descripcion = input("Ingrese la descripción de la muestra (máximo 32 caracteres): ")

    while not texto_valido(mst_descripcion, 32):
        print("Error: La descripción es obligatoria y de máximo 32 caracteres.")
        mst_descripcion = input("Ingrese la descripción de la muestra (máximo 32 caracteres): ")

    mst_descripcion = mst_descripcion.strip()

    mst_fk_personal = pedir_entero("Ingrese el ID del personal responsable: ", "El ID del personal")

    print("Tipo de muestra:")
    mst_tipo_muestra = elegir_opcion("Seleccione el tipo: ", TIPOS_MUESTRA)

    print("Estado de conservación:")
    mst_estado_conservacion = elegir_opcion("Seleccione el estado: ", ESTADOS_CONSERVACION)

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("SELECT ID_PERSONAL FROM PERSONAL WHERE ID_PERSONAL = %s", (mst_fk_personal,))

            if cursor.fetchone() is None:
                print(f"Error: No existe el personal {mst_fk_personal}.")
                return None

            # La tabla MUESTRA no tiene AUTO_INCREMENT: se calcula el siguiente ID
            cursor.execute("SELECT COALESCE(MAX(ID_MUESTRA), 0) + 1 AS nuevo FROM MUESTRA")
            id_muestra = cursor.fetchone()["nuevo"]

            cursor.execute(
                """INSERT INTO MUESTRA (ID_MUESTRA, MST_ESTADO_CONSERVACION, MST_DESCRIPCION, MST_TIPO_MUESTRA, MST_FK_PERSONAL) VALUES
                (%s, %s, %s, %s, %s)""",
                (
                    id_muestra,
                    mst_estado_conservacion,
                    mst_descripcion,
                    mst_tipo_muestra,
                    mst_fk_personal,
                ),
            )
            conexion.commit()
            print(f"Muestra {id_muestra} registrada exitosamente.")

            return {
                "id_muestra": id_muestra,
                "mst_estado_conservacion": mst_estado_conservacion,
                "mst_descripcion": mst_descripcion,
                "mst_tipo_muestra": mst_tipo_muestra,
                "mst_fk_personal": mst_fk_personal,
            }
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()


def actualizar_estado_muestra():
    listar_muestras()
    id_muestra = pedir_entero("Ingrese el ID de la muestra: ", "El ID de la muestra")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("SELECT ID_MUESTRA FROM MUESTRA WHERE ID_MUESTRA = %s", (id_muestra,))

            if cursor.fetchone() is None:
                print(f"Error: No existe la muestra {id_muestra}.")
                return None

            print("Nuevo estado de conservación:")
            nuevo_estado = elegir_opcion("Seleccione el estado: ", ESTADOS_CONSERVACION)

            cursor.execute(
                "UPDATE MUESTRA SET MST_ESTADO_CONSERVACION = %s WHERE ID_MUESTRA = %s",
                (nuevo_estado, id_muestra),
            )
            conexion.commit()
            print(f"Estado de la muestra {id_muestra} actualizado a '{nuevo_estado}'.")

            return nuevo_estado
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()


def eliminar_muestra():
    listar_muestras()
    id_muestra = pedir_entero("Ingrese el ID de la muestra a eliminar: ", "El ID de la muestra")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("SELECT ID_MUESTRA FROM MUESTRA WHERE ID_MUESTRA = %s", (id_muestra,))

            if cursor.fetchone() is None:
                print(f"Error: No existe la muestra {id_muestra}.")
                return None

            cursor.execute(
                "SELECT COUNT(*) AS total FROM REGISTRO_MUESTRA WHERE RM_FK_MUESTRA = %s",
                (id_muestra,),
            )

            if cursor.fetchone()["total"] > 0:
                print("Error: La muestra tiene recolecciones registradas, no se puede eliminar.")
                return None

            confirmacion = input(f"¿Confirma eliminar la muestra {id_muestra}? (s/n): ").strip().lower()

            if confirmacion != "s":
                print("Operación cancelada.")
                return None

            cursor.execute("DELETE FROM MUESTRA WHERE ID_MUESTRA = %s", (id_muestra,))
            conexion.commit()
            print(f"Muestra con ID {id_muestra} eliminada exitosamente.")

            return id_muestra
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()


# =====================================================================
# REGISTRO DE RECOLECCIÓN EN TERRENO (INSERT con validaciones)
# =====================================================================

def registrar_recoleccion():
    listar_expediciones()
    id_expedicion = pedir_entero("Ingrese el ID de la expedición: ", "El ID de la expedición")
    id_personal = pedir_entero("Ingrese el ID del personal responsable: ", "El ID del personal")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                "SELECT EXP_FK_BASE FROM EXPEDICION WHERE ID_EXPEDICION = %s", (id_expedicion,)
            )
            expedicion = cursor.fetchone()

            if expedicion is None:
                print(f"Error: No existe la expedición {id_expedicion}.")
                return None

            # El responsable debe ser participante de la expedición
            cursor.execute(
                "SELECT 1 FROM PERSONAL_PARTICIPAR WHERE ID_EXPEDICION = %s AND ID_PERSONAL = %s",
                (id_expedicion, id_personal),
            )

            if cursor.fetchone() is None:
                print(f"Error: El personal {id_personal} no participa en la expedición {id_expedicion}.")
                return None

            # El sector debe pertenecer a la base donde se realiza la expedición
            id_base = expedicion["EXP_FK_BASE"]
            cursor.execute(
                """SELECT ID_SECTOR AS id, SCT_NOMBRE_SECTOR AS sector, SCT_NIVEL_ACCESO AS acceso
                FROM SECTOR WHERE SCT_FK_BASE = %s ORDER BY ID_SECTOR""",
                (id_base,),
            )
            sectores = cursor.fetchall()

            if not sectores:
                print("Error: La base de la expedición no tiene sectores registrados.")
                return None

            print("Sectores disponibles en la base de la expedición:")
            imprimir_tabla(sectores)
            id_sector = pedir_entero("Ingrese el ID del sector: ", "El ID del sector")

            if id_sector not in [sector["id"] for sector in sectores]:
                print(f"Error: El sector {id_sector} no pertenece a la base de la expedición.")
                return None

            listar_muestras()
            id_muestra = pedir_entero("Ingrese el ID de la muestra: ", "El ID de la muestra")

            cursor.execute("SELECT ID_MUESTRA FROM MUESTRA WHERE ID_MUESTRA = %s", (id_muestra,))

            if cursor.fetchone() is None:
                print(f"Error: No existe la muestra {id_muestra}.")
                return None

            rm_fecha_recoleccion = pedir_fecha(
                "Ingrese la fecha de recolección (YYYY-MM-DD): ", "La fecha de recolección"
            )

            # ID_RECOLECION se numera dentro de cada expedición
            cursor.execute(
                "SELECT COALESCE(MAX(ID_RECOLECION), 0) + 1 AS nuevo FROM REGISTRO_MUESTRA WHERE ID_EXPEDICION = %s",
                (id_expedicion,),
            )
            id_recoleccion = cursor.fetchone()["nuevo"]

            cursor.execute(
                """INSERT INTO REGISTRO_MUESTRA (ID_RECOLECION, ID_EXPEDICION, RM_FECHA_RECOLECCION, RM_FK_PERSONAL_RESPONTABLE, RM_FK_BASE, RM_FK_SECTOR, RM_FK_MUESTRA) VALUES
                (%s, %s, %s, %s, %s, %s, %s)""",
                (
                    id_recoleccion,
                    id_expedicion,
                    rm_fecha_recoleccion,
                    id_personal,
                    id_base,
                    id_sector,
                    id_muestra,
                ),
            )
            conexion.commit()
            print(f"Recolección {id_recoleccion} registrada exitosamente en la expedición {id_expedicion}.")

            return {
                "id_recoleccion": id_recoleccion,
                "id_expedicion": id_expedicion,
                "rm_fecha_recoleccion": rm_fecha_recoleccion,
                "rm_fk_personal_responsable": id_personal,
                "rm_fk_base": id_base,
                "rm_fk_sector": id_sector,
                "rm_fk_muestra": id_muestra,
            }
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()


# =====================================================================
# REPORTES (procedimientos almacenados invocados con CALL)
# =====================================================================

def consultar_resumen_expedicion():
    listar_expediciones()
    id_expedicion = pedir_entero("Ingrese el ID de la expedición: ", "El ID de la expedición")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("CALL sp_resumen_expedicion(%s)", (id_expedicion,))
            datos = cursor.fetchall()

        if not datos:
            print(f"Error: No existe la expedición {id_expedicion}.")
            return None

        for clave, valor in datos[0].items():
            print(f"  {clave:<22}: {valor}")

        return datos[0]
    finally:
        conexion.close()


def consultar_muestras_por_tipo() -> list:
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("CALL sp_muestras_por_tipo()")
            datos = cursor.fetchall()

        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()


def consultar_recolecciones_por_base() -> list:
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("CALL sp_recolecciones_por_base()")
            datos = cursor.fetchall()

        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()


def consultar_historial_personal() -> list:
    id_personal = pedir_entero("Ingrese el ID del personal: ", "El ID del personal")

    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute("CALL sp_historial_personal(%s)", (id_personal,))
            datos = cursor.fetchall()

        print(f"Historial de expediciones del personal {id_personal}:")
        imprimir_tabla(datos)

        return datos
    finally:
        conexion.close()
