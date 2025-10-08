# Webサーバ用 Public Subnet

# ap-northeast-1a の AZ に Web サーバのサブネットを構築
resource "aws_subnet" "public_a" {
  # サブネットを構築するVPCのIDを設定
  # [vpc.tf] で記述したVPCを変数で指定
  vpc_id = aws_vpc.vpc.id

  # サブネットが使用する cidr を設定
  cidr_block = "10.0.1.0/24"

  # サブネットを配置する AZ を東京リージョン 1aに設定
  availability_zone = "ap-northeast-1a"

  # このサブネットで起動したインスタンスにパブリックIPを割り当てる
  map_public_ip_on_launch = true

  # タグ
  tags = {
    Name = "pub-a"
  }
}

# APIサーバ用 Private Subnet

# ap-northeast-1a の AZ に API サーバのサブネットを構築
resource "aws_subnet" "private_a" {
  # サブネットを構築するVPCのIDを設定
  # [vpc.tf] で記述したVPCを変数で指定
  vpc_id = aws_vpc.vpc.id

  # サブネットが使用する cidr を設定
  cidr_block = "10.0.2.0/24"

  # サブネットを配置する AZ を東京リージョン1aに設定
  availability_zone = "ap-northeast-1a"

  # タグ
  tags = {
    Name = "pri-a"
  }
}

# RDS 用 Subnet
# ap-northeast-1a の AZ に RDS 用のサブネットを構築
resource "aws_subnet" "dbsub_a" {
  # サブネットを構築するVPCのIDを設定
  # [vpc.tf]にて記述したVPCを変数で設定
  vpc_id = aws_vpc.vpc.id

  # サブネットが使用する cidr を設定
  cidr_block = "10.0.3.0/24"

  # サブネットを配置する AZ を東京リージョン1aに設定
  availability_zone = "ap-northeast-1a"

  # タグ
  tags = {
    Name = "db-subnet-1a"
  }
}

# ap-northeast-1c の AZ に RDS 用のサブネットを構築
resource "aws_subnet" "dbsub_c" {
  # サブネットを構築するVPCのIDを設定
  # [vpc.tf]にて記述したVPCを変数で設定
  vpc_id = aws_vpc.vpc.id

  # サブネットが使用する cidr を設定
  cidr_block = "10.0.4.0/24"

  # サブネットを配置する AZ を東京リージョン1aに設定
  availability_zone = "ap-northeast-1c"

  # タグ
  tags = {
    Name = "db-subnet-1c"
  }
}

# ALB マルチ AZ 用サブネットを構築
resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-1c"
  # このサブネットで起動したインスタンスにパブリックIPを割り当てる
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-c"
  }
}
