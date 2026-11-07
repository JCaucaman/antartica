import matplotlib.pyplot as plt
import pymysql.cursors

from validar import fechas, integer, string

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

            imprimir_tabla(cursor.fetchall())

            return cursor.fetchall()
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