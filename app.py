import boto3 # type: ignore
import pymysql # type: ignore
import os

def read_from_s3_and_push_to_rds(bucket_name, s3_file_key, rds_host, rds_user, rds_password, rds_db, rds_table):
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket=bucket_name, Key=s3_file_key)
    data = obj['Body'].read().decode('utf-8')

    try:
        conn = pymysql.connect(host=rds_host, user=rds_user, password=rds_password, db=rds_db)
        cursor = conn.cursor()
        cursor.execute(f"INSERT INTO {rds_table} (data) VALUES (%s)", (data,))
        conn.commit()
        conn.close()
    except pymysql.MySQLError as e:
        print("Could not connect to RDS")

if __name__ == "__main__":
    bucket_name = os.getenv('S3_BUCKET')
    s3_file_key = os.getenv('S3_FILE_KEY')
    rds_host = os.getenv('RDS_HOST')
    rds_user = os.getenv('RDS_USER')
    rds_password = os.getenv('RDS_PASS')
    rds_db = os.getenv('RDS_DB')
    rds_table = os.getenv('RDS_TABLE')

    read_from_s3_and_push_to_rds(bucket_name, s3_file_key, rds_host, rds_user, rds_password, rds_db, rds_table)
