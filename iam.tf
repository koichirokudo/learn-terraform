# EC2 用 iam_role の定義

# instance_profile が参照する IAM を作成

resource "aws_iam_role" "ec2_role" {
  # AWS 上での名称を入力
  name = "ec2-role"

  # IAM ロールのディレクトリ分けのような機能
  # 今回は厳密に管理する必要がないためデフォルトの / を利用する
  path = "/"

  # EC2が他のリソースへ一時的にアクセスする assume_role_policy を設定
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

# aws_iam_role とEC2 のinstance_profile を紐づけ

# aws_iam_instance_profile が参照する iam_role を選択
resource "aws_iam_instance_profile" "ec2_profile" {
  # AWS 上での名称を入力
  name = "ec2-profile"

  # aws_iam_role で作成した IAM Role を参照
  role = aws_iam_role.ec2_role.name
}
