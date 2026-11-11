from database import (
    actualizar_estado_muestra,
    consultar_historial_personal,
    consultar_muestras_por_tipo,
    consultar_participantes_expedicion,
    consultar_r1_bases_mas_expediciones,
    consultar_r2_distribucion_muestras,
    consultar_r3_duracion_vs_evaluacion,
    consultar_r4_paises_expediciones_participantes,
    consultar_r5_ocupacion_bases,
    consultar_r6_tipos_por_base_sector,
    consultar_r7_diversidad_sectores,
    consultar_r8_participantes_frecuentes,
    consultar_r9_expediciones_sobre_promedio_base,
    consultar_r10_sectores_sobre_promedio_base,
    consultar_r11_participantes_sobre_promedio,
    consultar_r12_bases_duracion_sobre_promedio,
    consultar_recolecciones_por_base,
    consultar_resumen_expedicion,
    delete_expedicion,
    eliminar_muestra,
    graficar_expediciones_por_año,
    listar_expediciones,
    listar_muestras,
    registrar_expedicion,
    registrar_muestra,
    registrar_recoleccion,
)
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
7. Listar muestras
8. Registrar muestra
9. Registrar recolección en terreno
10. Actualizar estado de una muestra
11. Eliminar muestra
12. Resumen de una expedición (procedimiento)
13. Muestras por tipo (procedimiento)
14. Recolecciones por base y sector (procedimiento)
15. Historial de expediciones de un integrante (procedimiento)

REQUERIMIENTOS DE INFORMACIÓN:
16. R1  Bases con más expediciones en un período (procedimiento)
17. R2  Distribución de muestras clasificadas (vista)
18. R3  Duración de expedición vs evaluación promedio (vista)
19. R4  Países con más expediciones y participantes (procedimiento)
20. R5  Ocupación de participantes por base (vista)
21. R6  Tipos de muestra por base y sector (vista)
22. R7  Diversidad de muestras por sector (vista)
23. R8  Participantes con más expediciones (vista)
24. R9  Expediciones sobre el promedio de su base (procedimiento)
25. R10 Sectores sobre el promedio de su base (procedimiento)
26. R11 Participantes sobre el promedio (procedimiento)
27. R12 Bases con duración sobre el promedio (procedimiento)

28. Salir
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
        listar_muestras()

    elif opcion == "8":
        registrar_muestra()

    elif opcion == "9":
        registrar_recoleccion()

    elif opcion == "10":
        actualizar_estado_muestra()

    elif opcion == "11":
        eliminar_muestra()

    elif opcion == "12":
        consultar_resumen_expedicion()

    elif opcion == "13":
        consultar_muestras_por_tipo()

    elif opcion == "14":
        consultar_recolecciones_por_base()

    elif opcion == "15":
        consultar_historial_personal()

    elif opcion == "16":
        consultar_r1_bases_mas_expediciones()

    elif opcion == "17":
        consultar_r2_distribucion_muestras()

    elif opcion == "18":
        consultar_r3_duracion_vs_evaluacion()

    elif opcion == "19":
        consultar_r4_paises_expediciones_participantes()

    elif opcion == "20":
        consultar_r5_ocupacion_bases()

    elif opcion == "21":
        consultar_r6_tipos_por_base_sector()

    elif opcion == "22":
        consultar_r7_diversidad_sectores()

    elif opcion == "23":
        consultar_r8_participantes_frecuentes()

    elif opcion == "24":
        consultar_r9_expediciones_sobre_promedio_base()

    elif opcion == "25":
        consultar_r10_sectores_sobre_promedio_base()

    elif opcion == "26":
        consultar_r11_participantes_sobre_promedio()

    elif opcion == "27":
        consultar_r12_bases_duracion_sobre_promedio()

    elif opcion == "28":
        print("Saliendo del sistema...")
        break

    else:
        print("Opción inválida. Por favor, seleccione una opción válida.")
