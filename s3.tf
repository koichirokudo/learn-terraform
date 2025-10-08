# Public バケット
resource "aws_s3_bucket" "public_bucket" {
  # バケット名称を任意の名前で定義
  bucket = var.public_bucket_name

  # このリソースを terraform destroy で削除可能にする
  force_destroy = true
}

# ACLを使わずにバケットポリシーで公開することが推奨されている
resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}

# クロスオリジンリソースシェアリングのルール設定
# 特定のオリジンに対しアクセスを許可する設定
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.public_bucket.id

  cors_rule {
    # アクセス元のオリジンを制限する
    # 今回は制限なし
    allowed_origins = ["*"]

    # 許容するHTTPメソッドのリクエストを制限
    # 読み取り専用のコンテンツであれば、セキュリティ上GETのみとすべき
    # 複数のメソッドを定義可能、以下対応できる
    # DELETE, GET, HEAD OPTIONS, PATCH, POST, PUT
    allowed_methods = ["GET"]

    # 許容する HTTP ヘッダーを制限
    # 特定のヘッダー情報で制限
    allowed_headers = ["*"]

    # ブラウザキャッシュ時間。秒単位で定義できる
    max_age_seconds = 3000
  }
}

# ALB アクセスログ用 S3 バケット
resource "aws_s3_bucket" "alb_access_log" {
  bucket        = var.alb_access_log_bucket_name
  force_destroy = true

  tags = {
    Name = var.alb_access_log_bucket_name
  }
}

# パブリックアクセスブロック（明示的に設定）
resource "aws_s3_bucket_public_access_block" "alb_access_log" {
  bucket                  = aws_s3_bucket.alb_access_log.id
  block_public_acls        = true
  block_public_policy      = false
  ignore_public_acls       = true
  restrict_public_buckets  = false
}

# ライフサイクル設定（以前の lifecycle_rule の代替）
resource "aws_s3_bucket_lifecycle_configuration" "alb_access_log" {
  bucket = aws_s3_bucket.alb_access_log.id

  rule {
    id     = "alb-access-log-expiration"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}

# バケットポリシー（以前の policy = <<POLICY の代替）
resource "aws_s3_bucket_policy" "alb_access_log_policy" {
  bucket = aws_s3_bucket.alb_access_log.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::582318560864:root"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_access_log.arn}/*"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_access_log.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.alb_access_log.arn
      }
    ]
  })
}
