variable "public_bucket_name" {
  type        = string
  description = "ALB アクセスログ用 S3 バケット名"
}

variable "alb_access_log_bucket_name" {
  type        = string
  description = "ALB アクセスログ用 S3 バケット名"
}

variable "global_ip" {
  type        = string
  description = "固定グローバルIPアドレス"
}
