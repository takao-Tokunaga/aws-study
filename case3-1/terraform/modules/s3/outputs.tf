output "bucket_id"                    { value = aws_s3_bucket.images.id }
output "bucket_arn"                   { value = aws_s3_bucket.images.arn }
output "bucket_regional_domain_name"  { value = aws_s3_bucket.images.bucket_regional_domain_name }
output "kms_key_arn"                  { value = aws_kms_key.images.arn }
