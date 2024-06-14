FROM python:3.8-slim

RUN pip install boto3 pymysql

COPY app.py /app/app.py

CMD ["python", "/app/app.py"]
