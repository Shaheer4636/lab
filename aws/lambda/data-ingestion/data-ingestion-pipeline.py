import boto3
import pandas as pd
import io
import os
from sqlalchemy import create_engine
from urllib.parse import unquote_plus
import psycopg2

# AWS clients
s3 = boto3.client("s3")
sns = boto3.client("sns")

# PostgreSQL connection string (Use Secrets Manager in production)
POSTGRES_CONN_STRING = (
    "postgresql://master:hGXB8gylxCUfCiXWjJFX@db-1.cx8606yqkzut.us-east-1.rds.amazonaws.com:5432/db-1"
)

# S3 File to Table mapping (whitelist)
TABLE_MAPPING = {
    "users.csv": "users",
    "test.csv": "test"
}

# Expected schema definitions
EXPECTED_COLUMNS = {
    "users": ["id", "name", "email"],
    "test": ["id", "score", "timestamp"]
}

# Optional SNS topic ARN
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:123456789012:your-topic-name"


def get_s3_object(bucket, key):
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        return response["Body"].read().decode("utf-8")
    except Exception as e:
        raise RuntimeError(f"Error fetching S3 object: {key}. Details: {str(e)}")


def load_csv_to_dataframe(csv_content):
    try:
        return pd.read_csv(io.StringIO(csv_content))
    except Exception as e:
        raise ValueError(f"Error loading CSV content into DataFrame. Details: {str(e)}")


def validate_schema(df, table_name):
    expected = EXPECTED_COLUMNS.get(table_name)
    actual = list(df.columns)

    if expected is None:
        raise ValueError(f"No schema defined for table '{table_name}'.")

    if actual != expected:
        raise ValueError(
            f"Schema mismatch for '{table_name}'.\nExpected: {expected}\nActual: {actual}"
        )


def append_to_postgres(df, table_name):
    try:
        engine = create_engine(POSTGRES_CONN_STRING)
        with engine.connect() as connection:
            df.to_sql(table_name, connection, if_exists="replace", index=False)
            print(f"Data written to table: {table_name}")
    except Exception as e:
        raise RuntimeError(f"Error writing to table '{table_name}'. Details: {str(e)}")


def send_notification(subject, message):
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject,
            Message=message
        )
    except Exception as e:
        print(f"Notification failed: {str(e)}")


def lambda_handler(event, context):
    try:
        # Step 1: Extract bucket and key
        bucket = event["Records"][0]["s3"]["bucket"]["name"]
        key = unquote_plus(event["Records"][0]["s3"]["object"]["key"])
        print(f"Triggered for file: s3://{bucket}/{key}")

        # Step 2: Validate file name
        if key not in TABLE_MAPPING:
            raise ValueError(f"File '{key}' is not whitelisted for processing.")

        table_name = TABLE_MAPPING[key]
        print(f"Target table: {table_name}")

        # Step 3: Download CSV from S3
        csv_content = get_s3_object(bucket, key)

        # Step 4: Load to DataFrame
        df = load_csv_to_dataframe(csv_content)
        print(f"Loaded {len(df)} rows from {key}")

        # Step 5: Schema validation
        validate_schema(df, table_name)
        print("Schema validated successfully.")

        # Step 6: Write to PostgreSQL
        append_to_postgres(df, table_name)

        # Step 7: Notify success (optional)
        send_notification(
            subject=f"[SUCCESS] Processed {key}",
            message=f"File '{key}' was successfully processed and loaded into table '{table_name}'."
        )

        return {
            "statusCode": 200,
            "body": f"File '{key}' successfully processed."
        }

    except Exception as e:
        print(f"[ERROR] {str(e)}")
        send_notification(
            subject=f"[ERROR] Processing failed: {key}",
            message=str(e)
        )
        return {
            "statusCode": 500,
            "body": f"Error processing file: {str(e)}"
        }
