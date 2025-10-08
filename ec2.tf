# Web サーバ設定

# 同ディレクトリ内の web.sh.tp1 を Terraform で扱えるようにdata 化

data "template_file" "web_shell" {
  template = file("${path.module}/web.sh.tpl")
}

# Web サーバ構築
resource "aws_instance" "web" {
  # [ami.tf]の ami を参照
  ami = data.aws_ami.amzn2023.id

  # インスタンスタイプを設定
  instance_type = "t4g.micro"

  # [keypair.tf]の鍵を参照
  key_name = aws_key_pair.auth.id

  # [iam.tf]のプロファイルを参照
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # [vpc_subnet.tf]を参照
  subnet_id = aws_subnet.public_a.id

  # [vpc_sg.tf]を参照
  vpc_security_group_ids = [
    aws_security_group.pub_a.id,
    aws_security_group.share.id
  ]

  # EBSのパラメータを設定
  root_block_device {
    # ボリュームの種類を指定
    # 今回は gp2 を選択。以下が選択可能な値
    # "standard", "gp2", "gp3", "io1", "sc1", "st1" 現在は他にもあると思う
    volume_type = "gp3"

    # ボリュームの容量を設定
    # 単位はGB AMI の内部 snapshot を使うために最低 30 GiB 以上必要なため
    volume_size = 30

    # インスタンス削除時にボリュームを併せて削除する設定
    delete_on_termination = true
  }

  tags = {
    Name = "web-instance"
  }

  # data 化した web.sh.tp1 を参照
  # 設定を base64 に encode して格納
  # encode する理由は、aws_instance などの user_data フィールドは
  # AWS EC2 User Data (起動時スクリプト) に対応している
  # user_data は base64 でエンコードされた文字列をして送信することが前提となっているから
  # データソースやテンプレートを経由する場合は、文字列中に改行や特殊文字が含まれているため、# 手動でやっといたほうが安全
  user_data_base64 = base64encode(data.template_file.web_shell.rendered)
}

# AP サーバ設定
data "template_file" "ap_shell" {
  template = file("${path.module}/ap.sh.tpl")
}

# AP サーバ構築
# 今回は ssh は web サーバ -> ap サーバという流れで作っている
resource "aws_instance" "ap" {
  # [ami.tf]の ami を参照
  ami = data.aws_ami.amzn2023.id

  # インスタンスタイプを設定
  instance_type = "t4g.micro"

  # [keypair.tf]の鍵を参照
  key_name = aws_key_pair.auth_priv.id

  # [iam.tf]のプロファイルを参照
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # [vpc_subnet.tf]を参照
  subnet_id = aws_subnet.private_a.id

  # [vpc_sg.tf]を参照
  vpc_security_group_ids = [aws_security_group.priv_a.id]

  # EBSのパラメータを設定
  root_block_device {
    # ボリュームの種類を指定
    # 今回は gp2 を選択。以下が選択可能な値
    # "standard", "gp2", "gp3", "io1", "sc1", "st1" 現在は他にもあると思う
    volume_type = "gp3"

    # ボリュームの容量を設定
    # 単位はGB AMI の内部 snapshot を使うために最低 30 GiB 以上必要なため
    volume_size = 30

    # インスタンス削除時にボリュームを併せて削除する設定
    delete_on_termination = true
  }

  tags = {
    Name = "ap-instance"
  }

  # data 化した web.sh.tp1 を参照
  # 設定を base64 に encode して格納
  # encode する理由は、aws_instance などの user_data フィールドは
  # AWS EC2 User Data (起動時スクリプト) に対応している
  # user_data は base64 でエンコードされた文字列をして送信することが前提となっているから
  # データソースやテンプレートを経由する場合は、文字列中に改行や特殊文字が含まれているため、# 手動でやっといたほうが安全
  user_data_base64 = base64encode(data.template_file.ap_shell.rendered)
}
