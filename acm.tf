# 証明書設定

# 証明書を構築

resource "aws_acm_certificate" "cert" {
  # 証明書を構築するドメイン
  # Route53 のドメインを直接指定
  domain_name = "terraform-learn.koichirokudo.info"

  # ドメインの認証方式
  # Email 認証/DNS 選択できる
  validation_method = "DNS"

  # タグ
  tags = {
    Name = "sslcertification"
  }
}

# 証明書の検証設定

# Route53レコード検証成否を確認
resource "aws_acm_certificate_validation" "cert" {
  # 証明書の ARN を設定
  certificate_arn = aws_acm_certificate.cert.arn

  # Route53に記述した検証レコードのFQDNを設定
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
