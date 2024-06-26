provider "aws" {
  region = "ap-south-1"
}

resource "aws_db_instance" "mydb" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "root"
  password               = "rootstark"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true 

  tags = {
    Name = "mydb"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "data-pipeline-bucket-unique-789123"
}

resource "aws_iam_role" "lambda_execution_role_1" {
  name = "lambda_execution_role_1"
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
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

resource "aws_ecr_repository" "my_repository" {
  name = "aws-data-pipeline-repo"
}

resource "aws_lambda_function" "my_lambda" {
  function_name    = "data_pipeline_lambda"
  role             = aws_iam_role.lambda_execution_role_1.arn
  package_type     = "Image"
  image_uri        = "${aws_ecr_repository.my_repository.repository_url}:latest"
  timeout          = 60

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.my_bucket.bucket
      S3_FILE_KEY = "idk.csv" 
      RDS_HOST  = aws_db_instance.mydb.address
      RDS_USER  = "root"
      RDS_PASS  = "rootstark"
      RDS_DB    = "mydb"
      RDS_TABLE = "names"  
    }
  }
}

resource "aws_iam_role" "ecr_access_role" {
  name = "ecr_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

data "aws_iam_policy_document" "assume_ecr_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::939533572395:role/ecr_access_role"]
    }
  }
}

data "aws_iam_policy" "ecr_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = data.aws_iam_policy.ecr_access_policy.arn
}
