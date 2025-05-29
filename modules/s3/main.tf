#Create s3 bucket
resource "aws_s3_bucket" "s3_bucket_endpoint" {
  bucket = var.s3_bucket_name

  tags      = {
    Name    = "${var.project_name}-s3bucket"
  }

}

#Upload file to a bucket
resource "aws_s3_object" "object" {
  for_each = fileset("html/", "*")
  bucket = aws_s3_bucket.s3_bucket_endpoint.id
  key    = each.value
  source = "html/${each.value}"
  etag = filemd5("html/${each.value}")
  content_type = "text/html"
 
}