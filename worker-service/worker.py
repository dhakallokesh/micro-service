import time
import mysql.connector
import redis

# Connect to MySQL
db = mysql.connector.connect(
    host="db",
    user="admin",
    password="admin",
    database="appdb"
)

cursor = db.cursor()

# Connect to Redis queue (optional)
r = redis.Redis(host='redis', port=6379, db=0)

def process_job(job_data):
    print(f"Processing job: {job_data}")
    cursor.execute("INSERT INTO jobs (data) VALUES (%s)", (job_data,))
    db.commit()

print("Worker started, waiting for jobs...")
while True:
    job = r.lpop("jobqueue")
    if job:
        process_job(job.decode("utf-8"))
    else:
        time.sleep(1)

