# インターネットゲートウェイ設定

resource "aws_internet_gateway" "igw" {
  # 作成するVPC IDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "igw"
  }
}

# NAT ゲートウェイ設定
resource "aws_nat_gateway" "ngw_pub_a" {
  # NAT ゲートウェイに関連付けるElastic IPアドレスの割当ID
  allocation_id = aws_eip.ngw_pub_a.id

  # NAT ゲートウェアを配置するサブネットのサブネットID
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "ngw-pub-a"
  }
}
