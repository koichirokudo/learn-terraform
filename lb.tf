# ALB 本体の設定

resource "aws_lb" "web" {
  # ALB 名称
  name = "web"

  # LBの種類を選択
  # network, application
  load_balancer_type = "application"

  # ALBの種類
  # true: AWS環境内部の通信を扱う Internal ALB
  # false: インターネットからの通信を扱う ALB
  internal = false

  # 利用するSGを設定
  security_groups = [
    aws_security_group.alb_web.id,
    aws_security_group.share.id
  ]

  # 利用するサブネット設定
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

  # 削除保護の設定
  # true: ALBの削除不可
  # false: ALBの削除可能
  enable_deletion_protection = false

  # accesslogの設定
  access_logs {
    # アクセスログの取得を有効化
    enabled = true

    # S3 への配置設定
    bucket = aws_s3_bucket.alb_access_log.bucket

    # ログをS3に配置する際のプレフィックス設定
    prefix = "web-alb"
  }

  tags = {
    Name = "web-alb"
  }
}

# ALB リスナーの構築
resource "aws_lb_listener" "web" {
  # Listerner 設定対象LBを指定
  # ALBをARNで設定
  load_balancer_arn = aws_lb.web.arn

  # インターネットから通信を待ち受けるポート
  port = "443"

  # インターネットから通信を待ち受けるプロトコル
  protocol = "HTTPS"

  # SSL証明書を通信に利用する
  certificate_arn = aws_acm_certificate.cert.arn

  # デフォルトで動作する設定
  default_action {
    # ルーティングアクションタイプを設定
    # forward: ターゲットグループにリクエストを転送する
    type = "forward"

    # リクエストを転送するターゲットグループを指定
    # ターゲットグループをARNで設定
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Target Groupの設定
resource "aws_lb_target_group" "web" {
  # ターゲットグループ名
  name = "web"

  # ターゲットが所属するVPCのID
  vpc_id = aws_vpc.vpc.id

  # ターゲットへの接続に利用するポート
  port = 80

  # ターゲットへの接続に利用するプロトコル
  protocol = "HTTP"
}

# WebサーバをALBのターゲットに登録
resource "aws_lb_target_group_attachment" "web" {
  # 登録するターゲットグループをARNで設定
  target_group_arn = aws_lb_target_group.web.arn

  # 登録するターゲットを指定
  target_id = aws_instance.web.id

  # インスタンスがトラフィックを受け付けるポートを設定
  port = 80
}
