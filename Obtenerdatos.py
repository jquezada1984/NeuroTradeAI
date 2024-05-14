# archivo: obtener_datos_mt5.py
from MT5Conexion import MT5Conexion 
import pandas as pd
from   datetime import datetime
import time
import json

def cargar_configuracion(archivo):
    with open(archivo, 'r') as file:
        return json.load(file)


configuracion = cargar_configuracion('configuracion.json')
broker = configuracion['broker1']

# Crear una instancia y conectar
conexion = MT5Conexion(broker)
if not conexion.conectar():
    print("Fallo al conectar con MT5. Verifique su configuración.")
    exit()

# Obtener datos
datos = conexion.copiarInformacion("2023-01-01", "2023-12-31", simbolo="EURUSD")

# Guardar datos en CSV
datos.to_csv("datos_eurusd.csv", index=False)
print("Datos guardados en 'datos_eurusd.csv'.")

# Desconectar
conexion.desconectar()