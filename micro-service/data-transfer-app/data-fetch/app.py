from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import pyodbc

app = FastAPI()

# Database Configuration
db_config = {
    "server": "mssql",  # Container name from docker-compose
    "database": "student_db",
    "username": "sa",
    "password": "Admin@123",
    "driver": "{ODBC Driver 17 for SQL Server}"
}

# Database Connection
def connect_to_db():
    return pyodbc.connect(
        f"DRIVER={db_config['driver']};"
        f"SERVER={db_config['server']};"
        f"DATABASE={db_config['database']};"
        f"UID={db_config['username']};"
        f"PWD={db_config['password']}"
    )

@app.get("/students", response_class=HTMLResponse)
def get_students():
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute("SELECT name, [class], degree FROM students")
    students = cursor.fetchall()
    conn.close()

    # Generate HTML table
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Student Records</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; }
            table { width: 80%; margin: auto; border-collapse: collapse; }
            th, td { border: 1px solid black; padding: 10px; text-align: left; }
            th { background-color: #f4f4f4; }
        </style>
    </head>
    <body>
        <h2>Student Records</h2>
        <table>
            <tr>
                <th>Name</th>
                <th>Class</th>
                <th>Degree</th>
            </tr>
    """
    for student in students:
        html_content += f"""
            <tr>
                <td>{student[0]}</td>
                <td>{student[1]}</td>
                <td>{student[2]}</td>
            </tr>
        """
    html_content += "</table></body></html>"
    return HTMLResponse(content=html_content)

# Handle requests for /favicon.ico to avoid 404 errors
@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return HTMLResponse(content="", status_code=204)
