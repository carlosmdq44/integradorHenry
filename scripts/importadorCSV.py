import os
import sys
import pathlib
import argparse
import pandas as pd
from config.db_config import get_connection

CSV_FOLDER = './data'

def importadorCSV(nombre_archivo):
    ruta_completa = os.path.join(CSV_FOLDER, nombre_archivo)
    nombre_tabla = os.path.splitext(nombre_archivo)[0]

    if not os.path.exists(ruta_completa):
        print(f"[ERROR] El archivo no existe: {ruta_completa}")
        return

    df = pd.read_csv(ruta_completa)
    print(f"[INFO] Filas detectadas: {len(df)}")

    print("[DEBUG] Columnas CSV:", list(df.columns))

    if df.empty:
        print("[AVISO] El CSV está vacío.")
        return

    try:
        conn = get_connection()
        print("[OK] Conexión MySQL abierta:", conn.is_connected())
        print("[DB] Base seleccionada:", conn.database)
    except Exception as err:
        print("[ERROR] No pude conectar a la base:", err)
        return
    cur = conn.cursor()

    for i, (_, fila) in enumerate(df.iterrows(), start=1):
        columnas = ', '.join(fila.index)
        valores = ', '.join(['%s'] * len(fila))
        sql = f"INSERT INTO {nombre_tabla} ({columnas}) VALUES ({valores})"
        try:
            cur.execute(sql, tuple(fila))
        except Exception as e:
            print(f"[ERROR] Fila {i} falló: {e}")
            conn.rollback()
            break

    conn.commit()
    cur.close()
    conn.close()
    print(f"[FIN] Tabla '{nombre_tabla}' importada y conexión cerrada.\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Importar un CSV específico a la base de datos.")
    parser.add_argument('--archivo', required=True, help='Nombre del archivo CSV (ej: cities.csv)')
    args = parser.parse_args()

    importadorCSV(args.archivo)