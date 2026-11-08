from datetime import datetime

def fechas(fecha: str):
    try:
        datetime.strptime(fecha, "%Y-%m-%d")
        return True
    except ValueError:
        return False

def integer (numero: str):
    try:
        int(numero)
        return True
    except ValueError:
        return False

def string (texto: str):
    if texto.isalpha():
        return True
    else:
        return False

def texto_valido(texto: str, maximo: int = 32):
    if 0 < len(texto.strip()) <= maximo:
        return True
    else:
        return False
