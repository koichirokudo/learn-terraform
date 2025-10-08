# Elastic IP の設定

# EIPを"ngw-pub-a"という名称で作成

resource "aws_eip" "ngw_pub_a" {
  # EIP が VPC にあるかどうか
  # true / false が選択可能
  domain = "vpc"

  # タグを設定
  tags = {
    Name = "ngw-pub-a"
  }
}
