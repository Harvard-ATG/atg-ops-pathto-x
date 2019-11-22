locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.pathto_static_website_s3_bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront distribution for the path-to static website."
  default_root_object = "index.html"

  aliases = ["path-to.org", "path-to.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
      geo_restriction {
          restriction_type = "none"
      }
  }

  viewer_certificate {
      acm_certificate_arn = "${var.acm_certificate_arn}"
      minimum_protocol_version = "TLSv1.1_2016"
      ssl_support_method = "sni-only"
  }
}