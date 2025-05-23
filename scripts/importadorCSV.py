import os
import pandas as pd
from config.db_config import get_connection

CSV_FOLDER = './csv'  # Carpeta donde están los CSV

# Conexión y cursor
conexion = get_connection()
cursor = conexion.cursor()

def importar_csv(nombre_archivo):
    ruta_completa = os.path.join(CSV_FOLDER, nombre_archivo)
    nombre_tabla = os.path.splitext(nombre_archivo)[0]
    df = pd.read_csv(ruta_completa)

    print(f'📥 Importando: {nombre_archivo} → {nombre_tabla}')

    for _, fila in df.iterrows():
        columnas = ', '.join(fila.index)
        valores = ', '.join(['%s'] * len(fila))
        sql = f"INSERT INTO {nombre_tabla} ({columnas}) VALUES ({valores})"
        cursor.execute(sql, tuple(fila))

    conexion.commit()
    print(f'✅ Tabla "{nombre_tabla}" importada correctamente.\n')

# Ejecutar importación para cada archivo .csv
for archivo in os.listdir(CSV_FOLDER):
    if archivo.endswith('.csv'):
        try:
            importar_csv(archivo)
        except Exception as e:
            print(f'⚠ Error al importar {archivo}: {e}')

# Cerrar recursos
cursor.close()
conexion.close()
print("🚀 Importación finalizada.")
