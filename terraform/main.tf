resource "aws_s3_bucket" "pathto_codepipeline_bucket" {
  bucket = "pathto-x-codepipeline-artifacts"
}

resource "aws_s3_bucket_public_access_block" "pathto_codepipeline_bucket" {
  bucket                  = aws_s3_bucket.pathto_codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "pathto_codepipeline_role" {
  name = "AWSCodePipelineServiceRole-us-east-1-pathto-x"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "pathto_codepipeline_policy" {
  name = "AWSCodePipelineServiceRolePolicy-us-east-1-pathto-x"
  role = aws_iam_role.pathto_codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.pathto_codepipeline_bucket.arn,
          "${aws_s3_bucket.pathto_codepipeline_bucket.arn}/*",
          aws_s3_bucket.pathto_static_website_s3_bucket.arn,
          "${aws_s3_bucket.pathto_static_website_s3_bucket.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["codeconnections:UseConnection"]
        Resource = aws_codeconnections_connection.pathto_github.arn
      }
    ]
  })
}

resource "aws_codeconnections_connection" "pathto_github" {
  name          = "pathto-x-github"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "pathto_codepipeline" {
  name     = "pathto-x"
  role_arn = aws_iam_role.pathto_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pathto_codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = aws_codeconnections_connection.pathto_github.arn
        FullRepositoryId = "pathto-x/pathto-x.github.io"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        BucketName = aws_s3_bucket.pathto_static_website_s3_bucket.id
        Extract    = "true"
      }
    }
  }
}

resource "aws_s3_bucket" "pathto_static_website_s3_bucket" {
  bucket = "pathto-x"
}

resource "aws_s3_bucket_ownership_controls" "pathto_static_website_s3_bucket" {
  bucket = aws_s3_bucket.pathto_static_website_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pathto_static_website_s3_bucket" {
  bucket                  = aws_s3_bucket.pathto_static_website_s3_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "pathto_static_website_s3_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.pathto_static_website_s3_bucket,
    aws_s3_bucket_public_access_block.pathto_static_website_s3_bucket,
  ]
  bucket = aws_s3_bucket.pathto_static_website_s3_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "pathto_static_website_s3_bucket" {
  depends_on = [aws_s3_bucket_public_access_block.pathto_static_website_s3_bucket]
  bucket     = aws_s3_bucket.pathto_static_website_s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["arn:aws:s3:::pathto-x/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "pathto_static_website_s3_bucket" {
  bucket = aws_s3_bucket.pathto_static_website_s3_bucket.id
  index_document {
    suffix = "index.html"
  }
}
