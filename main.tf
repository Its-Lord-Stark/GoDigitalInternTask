provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecr_repository" "my_repository" {
  name = "aws-data-pipeline-repo"
}

resource "aws_rds_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "data_pipeline_db"
  username             = "root"
  password             = "root"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "data-pipeline-bucket-unique"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AWSGlueServiceRole"
  ]
}

resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "data_pipeline_lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.my_bucket.bucket
      S3_FILE_KEY = "data_file_key"  # Adjust as needed
      RDS_HOST  = aws_rds_instance.my_rds.address
      RDS_USER  = "root"
      RDS_PASS  = "root"
      RDS_DB    = "data_pipeline_db"
      RDS_TABLE = "names"  
    }
  }
}
