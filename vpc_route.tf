# ルートテーブル作成
# Route Table とは、サブネットに配置しているインスタンス等がどこに通信するかを定めたものです。
# Public サブネット用とPrivate サブネット用、2つ用意する

# Public Subnet 用 Route Table

# ルートテーブルを定義
resource "aws_route_table" "public_a" {
  # ルートテーブルを構築する VPC を変数で指定
  # [vpc.tf] にて記述した VPC を変数で指定
  vpc_id = aws_vpc.vpc.id

  # 通信経路の設定
  # [vpc_gw.tf]にて記述したIGWを利用
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  # タグ
  tags = {
    Name = "rtb-pub-a"
  }
}

# パブリックサブネットとルートテーブルを関連付ける
resource "aws_route_table_association" "public_a" {
  # 関連付けたいサブネットIDを設定
  # [vpc_subnet.tf] にて記述したパブリックサブネットのIDを設定
  subnet_id = aws_subnet.public_a.id

  # 用意したルートテーブルのIDを設定
  route_table_id = aws_route_table.public_a.id
}

# Private Subnet 用 Route Table
resource "aws_route_table" "private_a" {
  # ルートテーブルを構築する VPC を変数で指定
  # [vpc.tf] にて記述した VPC を変数で指定
  vpc_id = aws_vpc.vpc.id

  # 通信経路の設定
  # [vpc_gw.tf]にて記述したNATゲートウェイを利用
  route {
    nat_gateway_id = aws_nat_gateway.ngw_pub_a.id
    cidr_block = "0.0.0.0/0"
  }

  # タグ
  tags = {
    Name = "rtb-pri-a"
  }
}

# プライベートサブネットとルートテーブルを関連付ける
resource "aws_route_table_association" "private_a" {
  # 関連付けたいサブネットIDを設定
  # [vpc_subnet.tf] にて記述したパブリックサブネットのIDを設定
  subnet_id = aws_subnet.private_a.id

  # 用意したルートテーブルのIDを設定
  route_table_id = aws_route_table.private_a.id
}

# パブリックサブネット ap-northeast-1c 用のルートテーブルを定義
resource "aws_route_table" "public_c" {
  vpc_id = aws_vpc.vpc.id
  # 通信経路の設定
  # [vpc_gw.tf]にて記述したIGWを利用
  # IGWを経由するすべてのIPv4をルーティング
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "rtb-pub-c"
  }
}

# パブリックサブネットとルートテーブルを紐づけ
resource "aws_route_table_association" "public_c" {
  subnet_id = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_c.id
}
