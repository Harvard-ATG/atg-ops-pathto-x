resource "aws_s3_bucket" "pathto_codepipeline_bucket" {
    bucket = "pathto-x-codepipeline-artifacts"
    acl = "private"
}
resource "aws_iam_role" "pathto_codepipeline_role" {
  name = "AWSCodePipelineServiceRole-us-east-1-pathto-x"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "pathto_codepipeline_policy" {
  name = "AWSCodePipelineServiceRolePolicy-us-east-1-pathto-x"
  role = aws_iam_role.pathto_codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.pathto_codepipeline_bucket.arn}",
        "${aws_s3_bucket.pathto_codepipeline_bucket.arn}/*"
      ]
    }
  ]
}
EOF
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
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner  = "pathto-x"
        Repo   = "pathto-x.github.io"
        Branch = "master"
        OAuthToken = var.github_oauth_token
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
        Extract = "true"
      }
    }
  }
}

resource "aws_s3_bucket" "pathto_static_website_s3_bucket" {
  bucket = "pathto-x"
  acl    = "public-read"
  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Sid":"PublicRead",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject", "s3:PutObject"],
        "Resource":["arn:aws:s3:::pathto-x/*"]
      }
    ]
}
EOF
  website {
    index_document = "index.html"
  }
}

