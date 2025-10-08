# Webサーバ用 公開鍵設定

# template_file として読み込み、レンダリング可能な状態に設定
data "template_file" "ssh_key" {
  # ローカルから web サーバ用の公開鍵を読み込み
  template = file("~/.ssh/terraform.pub")
}

# EC2 キーペアリソース設定
# EC2 インスタンスへのログインアクセスを制御するために使用
resource "aws_key_pair" "auth" {
  # Webサーバ用のキーペア名を定義
  key_name = "terraform.pub"

  # template_file の Web サーバ用の公開鍵を設定
  public_key = data.template_file.ssh_key.rendered
}

# API サーバ用 公開鍵設定
data "template_file" "ssh_key_priv" {
  # ローカルから web サーバ用の公開鍵を読み込み
  template = file("~/.ssh/terraform_ap.pub")
}

# EC2 キーペアリソース設定
# EC2 インスタンスへのログインアクセスを制御するために使用
resource "aws_key_pair" "auth_priv" {
  # Webサーバ用のキーペア名を定義
  key_name = "terraform_ap.pub"

  # template_file の Web サーバ用の公開鍵を設定
  public_key = data.template_file.ssh_key_priv.rendered
}

