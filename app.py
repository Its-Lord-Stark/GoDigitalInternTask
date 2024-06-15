import boto3
import pymysql
import os

def create_table_if_not_exists(cursor, names):
    create_table_query = """
    CREATE TABLE IF NOT EXISTS names (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL
    );
    """
    cursor.execute(create_table_query)

def read_from_s3_and_push_to_rds(bucket_name, s3_file_key, rds_host, rds_user, rds_password, rds_db, rds_table):
    try:
        s3 = boto3.client('s3')
        obj = s3.get_object(Bucket=bucket_name, Key=s3_file_key)
        data = obj['Body'].read().decode('utf-8')
        nameslist = data.splitlines()

        conn = pymysql.connect(host=rds_host, user=rds_user, password=rds_password, db=rds_db)
        cursor = conn.cursor()

        # Create table if it does not exist
        create_table_if_not_exists(cursor, names)

        for name in nameslist:
            cursor.execute(f"INSERT INTO {rds_table} (name) VALUES (%s)", (name,))
        conn.commit()
        conn.close()

    except Exception as e:
        print(f"Error: {e}")
        print("Could not connect to RDS due to an issue")

def lambda_handler(event, context):
    bucket_name = os.getenv('S3_BUCKET')
    s3_file_key = os.getenv('S3_FILE_KEY')
    rds_host = os.getenv('RDS_HOST')
    rds_user = os.getenv('RDS_USER')
    rds_password = os.getenv('RDS_PASS')
    rds_db = os.getenv('RDS_DB')
    rds_table = os.getenv('RDS_TABLE')

    read_from_s3_and_push_to_rds(bucket_name, s3_file_key, rds_host, rds_user, rds_password, rds_db, rds_table)

    return {
        'statusCode': 200,
        'body': 'Data inserted into RDS successfully!'
    }
