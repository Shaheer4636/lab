from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pyodbc
import time

app = FastAPI()

# Enable CORS (Modify for production security)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (* means any frontend can access)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# Database Configuration (Match with docker-compose.yml)
db_config = {
    "server": "mssql",  # Use service name from docker-compose
    "database": "student_db",
    "username": "sa",
    "password": "Admin@123",  # Fixed password mismatch
    "driver": "{ODBC Driver 17 for SQL Server}",
}

# Database Connection Function
def connect_to_db():
    retries = 5
    while retries > 0:
        try:
            conn = pyodbc.connect(
                f"DRIVER={db_config['driver']};"
                f"SERVER={db_config['server']},1433;"  # Explicit port
                f"DATABASE={db_config['database']};"
                f"UID={db_config['username']};"
                f"PWD={db_config['password']}"
            )
            conn.autocommit = True
            return conn
        except Exception as e:
            print(f"Database connection failed: {e}. Retrying in 5 seconds...")
            time.sleep(5)
            retries -= 1
    raise Exception("Could not connect to database after multiple attempts.")

# Connect to database
conn = connect_to_db()
cursor = conn.cursor()

# Ensure the database and table exist
def init_db():
    try:
        cursor.execute("SELECT name FROM sys.databases WHERE name = 'student_db'")
        db_exists = cursor.fetchone()
        if not db_exists:
            cursor.execute("CREATE DATABASE student_db")
            print("Database created.")

        cursor.execute("USE student_db")
        cursor.execute(
            """
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'students')
            CREATE TABLE students (
                id INT IDENTITY(1,1) PRIMARY KEY,
                name NVARCHAR(255) NOT NULL,
                [class] NVARCHAR(100) NOT NULL,  -- Enclosed in brackets
                degree NVARCHAR(255) NOT NULL
            )
            """
        )
        print("Table ensured.")
    except Exception as e:
        print(f"Database initialization error: {e}")

init_db()  # Run at startup

# Data Model
class Student(BaseModel):
    name: str
    class_name: str
    degree: str

@app.post("/add-student")
def add_student(student: Student):
    try:
        sql = "INSERT INTO students (name, [class], degree) VALUES (?, ?, ?)"
        cursor.execute(sql, (student.name, student.class_name, student.degree))
        return {"message": "Student added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
