import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='tu_contraseña',   # Cambialo según tu setup
        database='sales_company'
    )