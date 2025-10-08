# Webサーバが端末のグローバルIPからSSH/SFTPとHTTPを受け入れるSG設定

# WebサーバがSSHとHTTPを受け付けるSGの構築
# SSMのほうが本当はいいと思う
resource "aws_security_group" "pub_a" {
  # セキュリティグループ名を設定
  name = "sg_pub_a"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "sg-pub-a"
  }
}

# アウトバウンド側のルール設定
resource "aws_security_group_rule" "egress_pub_a" {
  # egress を設定
  type = "egress"

  # ポートの範囲設定
  # すべてのトラフィックを許可する場合はいずれも 0 で設定する
  from_port = 0
  to_port = 0

  # プロトコル設定
  protocol = "-1"

  # 許可するIPの範囲を設定
  # 以下はすべてのIPv4トラフィックを許容する設定
  cidr_blocks = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

# SSH/SFTP を受け入れる設定
resource "aws_security_group_rule" "ingress_pub_a_22" {
  # ingress を設定
  type = "ingress"
  
  # ポートの範囲設定
  from_port = "22"
  to_port = "22"

  # プロトコルは tcp を設定
  protocol = "tcp"

  # 許可するIPの範囲を設定
  # グローバルIPアドレス（自分の）
  cidr_blocks = [var.global_ip]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

# HTTP を受け入れる設定
resource "aws_security_group_rule" "ingress_pub_a_80" {
  # このリソースが通信を受け入れる設定であることを定義
  # ingress を設定
  type = "ingress"

  # ポートの範囲設定
  from_port = "80"
  to_port = "80"

  # プロトコルは tcp を設定
  protocol = "tcp"

  # 許可するIPの範囲を設定
  # 自身のグローバルIPを記入
  cidr_blocks = [var.global_ip]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

# AP サーバが Web サーバから VPC 内部IPを利用しSSHを受けるSG設定

# AP サーバが Web サーバから SSH を受け付ける SG 構築
resource "aws_security_group" "priv_a" {
  # SG名を設定
  name = "sg_priv_a"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグ
  tags = {
    Name = "sg-priv-a"
  }
}

# アウトバウンド側の設定
resource "aws_security_group_rule" "egress_priv_a" {
  # このリソースが通信を受け入れる設定であることを定義
  # egress を設定
  type = "egress"

  # ポートの範囲設定
  # すべてのトラフィックを許可する場合いずれも 0 で設定
  from_port = 0
  to_port = 0

  # プロトコル設定
  protocol = "-1"

  # 許可するIPの範囲を設定
  # 以下はすべてのIPv4トラフィックを許容する設定
  cidr_blocks = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.priv_a.id
}


# SSH/SFTP を受け入れる設定
resource "aws_security_group_rule" "ingress_priv_a_22" {
  # このリソースが通信を受け入れる設定であることを定義
  # ingress を設定
  type = "ingress"
  
  # ポートの範囲設定
  from_port = "22"
  to_port = "22"

  # プロトコルは tcp を設定
  protocol = "tcp"

  # 許可するIPの範囲を設定
  cidr_blocks = ["10.0.1.0/24"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.priv_a.id
}

# RDSがAPサーバから3306ポートを利用した通信を受け入れるSG構築
resource "aws_security_group" "rds_sg" {
  # セキュリティグループ名を設定
  name = "rds-sg"

  # セキュリティグループを構築する VPC の ID を設定
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rds-sg"
  }
}

# アウトバウンドルールの設定
resource "aws_security_group_rule" "egress_rds_sg" {
  # このリソースがアウトバウンド側を設定することを定義
  # egress を設定
  type = "egress"

  # ポートの範囲設定
  # すべてのトラフィックを許可する場合いずれも0で設定
  from_port = 0
  to_port = 0

  # プロトコル設定
  protocol = "-1"

  # 許可する IP の範囲を設定
  # 以下はすべてのIPv4トラフィックを許容する設定
  cidr_blocks = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.rds_sg.id
}

# インバウンドルールの設定：3306ポートを受け入れる設定
resource "aws_security_group_rule" "ingress_rds_3306" {
  # egress を設定
  type = "ingress"

  # ポートの範囲設定
  # すべてのトラフィックを許可する場合はいずれも 0 で設定する
  from_port = "3306"
  to_port = "3306"

  # プロトコル設定
  protocol = "tcp"

  # 許可するIPの範囲を設定
  # 以下はすべてのIPv4トラフィックを許容する設定
  cidr_blocks = ["10.0.2.0/24"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.rds_sg.id
}

# ALB が端末のグローバルIPからHTTPSを受け入れるSG設定

# ALB が HTTPS を受け入れる SG 構築
resource "aws_security_group" "alb_web" {
  # SG名
  name = "alb_web"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "alb-web"
  }
}

# アウトバウンドルール
resource "aws_security_group_rule" "egress_alb_web" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_web.id
}

# インバウンドルール
resource "aws_security_group_rule" "ingress_alb_web_443" {
  type = "ingress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  # 自身のグローバルIPアドレス
  cidr_blocks = [var.global_ip]
  security_group_id = aws_security_group.alb_web.id
}

# ALB - Web サーバ間の通信を許可するSG設定(共通で利用する)
resource "aws_security_group" "share" {
  name = "share"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "share"
  }
}

# アウトバウンドルール
resource "aws_security_group_rule" "egress_share" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.share.id
}

# インバウンドルール
# share SGを利用するリソース同士がすべての通信を受け入れる設定
resource "aws_security_group_rule" "ingress_share_self" {
  type = "ingress"
  from_port = "0"
  to_port = "0"
  protocol = "-1"
  # 自分自身のセキュリティグループIDを指定
  self = true
  security_group_id = aws_security_group.share.id
}

