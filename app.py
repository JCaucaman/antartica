from database import delete_expedicion, listar_expediciones, registrar_expedicion, consultar_participantes_expedicion, graficar_expediciones_por_año
from init_db import crear_base_de_datos_y_tablas


while True:
    print("""

SISTEMA DE EXPEDICIONES EN LA ANTARTICA:

=========================================
1. Crear datos y tablas
2. Listar expediciones
3. Registrar expedición
4. Consultar participantes por expedición
5. Graficar expediciones por año
6. Eliminar expedición
7. Salir
=========================================
""")
    opcion = input("Seleccione una opción:")

    if opcion == "1":
        crear_base_de_datos_y_tablas()
        print("Base de datos, datos y tablas creadas exitosamente.")

    elif opcion == "2":
        listar_expediciones()

    elif opcion == "3":
        registrar_expedicion()

    elif opcion == "4":
        consultar_participantes_expedicion()

    elif opcion == "5":
        graficar_expediciones_por_año()

    elif opcion == "6":
        delete_expedicion()

    elif opcion == "7":
        print("Saliendo del sistema...")
        break

    else:
        print("Opción inválida. Por favor, seleccione una opción válida.")