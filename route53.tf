# Public Hosted Zone 参照の設定

# サブドメイン用のパブリックホストゾーン作成
resource "aws_route53_zone" "main" {
  name = "terraform-learn.koichirokudo.info"
}

# 公開 Web サーバ用レコード設定
# ALB用
resource "aws_route53_record" "web" {
  # レコードを設定
  # zone_id を設定する必要がある
  zone_id = aws_route53_zone.main.zone_id
  # main ドメインの Zone Apex をレコード登録
  name = "app" # => app.terraform-learn.koichirokudo.info

  # レコードタイプ A レコード
  type = "A"
/*
  # TTL
  ttl = "300"

  # A レコードに登録する値を設定
  # WebサーバのパブリックIPを設定
  records = [aws_instance.web.public_ip]
}
*/
  alias {
    # ALBのDNS名を設定
    name = aws_lb.web.dns_name

    # ALBの所属するゾーンIDを設定
    zone_id = aws_lb.web.zone_id

    # このレコードにヘルスチェックを行う
    evaluate_target_health = true
  }
}

# Internal Hosted Zone 設定
# VPC内部で利用できるドメインを構築する
resource "aws_route53_zone" "in" {
  # Zone名を設定
  # 任意の値を設定
  name = "internal" # => internal.terraform-learn.koichirokudo.info

  # 所属するVPCとリージョンを設定
  vpc {
    vpc_id = aws_vpc.vpc.id
    vpc_region = "ap-northeast-1"
  }

  tags = {
    Name = "Internal DNS Zone"
  }
}

# 内部APサーバ用レコード設定
resource "aws_route53_record" "ap_in" {
  # レコードを記述するホストゾーンID
  zone_id = aws_route53_zone.in.zone_id

  # レコード名を設定
  name = "ap"

  # レコードタイプ
  type = "A"

  # TTL
  ttl = "300"

  # Aレコードに登録する値を設定
  # AP サーバのプライベートIPを設定
  records = [aws_instance.ap.private_ip]
}

# 内部 RDS 用レコード設定 書き込み用
resource "aws_route53_record" "aurora_clstr_in" {
  # レコードを記述するホストゾーンID
  zone_id = aws_route53_zone.in.zone_id

  # レコード名を設定
  name = "rds"

  # レコードタイプ
  type = "CNAME"

  # TTL
  ttl = "300"

  # CNAME レコードに登録する値を設定
  # RDSの書き込み用エンドポイント
  records = [aws_rds_cluster.aurora_clstr.endpoint]
}


# 内部 RDS 用レコード設定 読み込み用
resource "aws_route53_record" "aurora_clstr_ro_in" {
  # レコードを記述するホストゾーンID
  zone_id = aws_route53_zone.in.zone_id

  # レコード名を設定
  name = "rds-ro"

  # レコードタイプ
  type = "CNAME"

  # TTL
  ttl = "300"

  # CNAME レコードに登録する値を設定
  # RDSの書き込み用エンドポイント
  records = [aws_rds_cluster.aurora_clstr.reader_endpoint]
}

# ACM 用DNS検証設定
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

