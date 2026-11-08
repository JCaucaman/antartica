import pymysql.cursors

RUTA_SQL = "C:\\dev\\work-space-1\\antartica\\db\\FreeSQL-demo (3).sql"
RUTA_SQL_DATOS = "C:\\dev\\work-space-1\\antartica\\db\\datos_iniciales.sql"
RUTA_SQL_PROCEDIMIENTOS = "C:\\dev\\work-space-1\\antartica\\db\\03_procedimientos.sql"

def conectar_not_with_bd():
    return pymysql.connect(
        host="localhost",
        user="root",
        password="",
        cursorclass=pymysql.cursors.DictCursor,
    )


def createdb():
    connection = conectar_not_with_bd()
    try:
        with connection.cursor() as cursor:
            cursor.execute("CREATE DATABASE IF NOT EXISTS antartida")
        connection.commit()
    finally:
        connection.close()


def tablas_existen(cursor):
    cursor.execute("SHOW TABLES")
    return len(cursor.fetchall()) > 0


def datos_existen(cursor):
    cursor.execute("SELECT COUNT(*) AS total FROM PAIS")
    return cursor.fetchone()["total"] > 0


def separar_sentencias(sql_script):
    """
    Divide un script SQL en sentencias respetando DELIMITER.
    (DELIMITER es un comando del cliente MySQL, no del servidor: por eso
    Python debe interpretarlo para poder crear los procedimientos, que
    llevan ';' dentro de BEGIN ... END.)
    """
    delimitador = ";"
    sentencias = []
    actual = []

    for linea in sql_script.splitlines():
        limpia = linea.strip()

        if not actual and (not limpia or limpia.startswith("--")):
            continue

        if limpia.upper().startswith("DELIMITER"):
            delimitador = limpia.split()[1]
            continue

        actual.append(linea)

        if limpia.endswith(delimitador):
            sentencia = "\n".join(actual).strip()
            sentencias.append(sentencia[: -len(delimitador)].strip())
            actual = []

    if "".join(actual).strip():
        sentencias.append("\n".join(actual).strip())

    return sentencias


def ejecutar_script(cursor, ruta):
    with open(ruta, "r", encoding="utf-8") as f:
        sql_script = f.read()

    for sentencia in separar_sentencias(sql_script):
        cursor.execute(sentencia)


def crear_tablas():
    """Crea las tablas, solo si la BD está vacía."""
    connection = conectar_not_with_bd()
    try:
        with connection.cursor() as cursor:
            cursor.execute("USE antartida")

            if tablas_existen(cursor):
                print("La base de datos ya tiene tablas, se omite la carga inicial.")
                return

            ejecutar_script(cursor, RUTA_SQL)

        connection.commit()
        print("Tablas creadas.")
    finally:
        connection.close()

def crear_datos():
    """Inserta los datos iniciales, solo si las tablas están vacías."""
    connection = conectar_not_with_bd()
    try:
        with connection.cursor() as cursor:
            cursor.execute("USE antartida")

            if datos_existen(cursor):
                print("Las tablas ya tienen datos, se omite la carga inicial.")
                return

            ejecutar_script(cursor, RUTA_SQL_DATOS)

        connection.commit()
        print("Datos iniciales creados.")
    finally:
        connection.close()


def crear_procedimientos():
    """Crea los procedimientos almacenados (si ya existían los vuelve a crear)."""
    connection = conectar_not_with_bd()
    try:
        with connection.cursor() as cursor:
            cursor.execute("USE antartida")
            ejecutar_script(cursor, RUTA_SQL_PROCEDIMIENTOS)

        connection.commit()
        print("Procedimientos almacenados creados.")
    finally:
        connection.close()


def crear_base_de_datos_y_tablas():
    createdb()
    crear_tablas()
    crear_datos()
    crear_procedimientos()
