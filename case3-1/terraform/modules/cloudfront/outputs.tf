output "distribution_domain_name"   { value = aws_cloudfront_distribution.main.domain_name }
output "distribution_arn"           { value = aws_cloudfront_distribution.main.arn }
output "distribution_id"            { value = aws_cloudfront_distribution.main.id }
output "key_group_id"               { value = length(aws_cloudfront_key_group.images) > 0 ? aws_cloudfront_key_group.images[0].id : "" }
output "cloudfront_public_key_id"   { value = length(aws_cloudfront_public_key.images) > 0 ? aws_cloudfront_public_key.images[0].id : "" }
