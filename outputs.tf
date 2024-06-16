// output "ecr_repository_url" {
//   value = aws_ecr_repository.my_repository.repository_url
// }

output "rds_endpoint" {
  value = aws_db_instance.mydb.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}