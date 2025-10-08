# AMI設定

# AMI の Data Source を "amzn2023" という名称で作成
data "aws_ami" "amzn2023" {
  # 複数の結果が返された場合は、最新のAMIを使用
  most_recent = true

  # 検索を制限する AMI の所有者リスト
  # AWS アカウントIDやAWS所有者のエイリアスを設定可能
  # 以下は、AWS所有者のエイリアスの例
  # ["amazon", "aws-marketplace", "microsoft"]
  # Amazon配布のAMIを使用する
  owners = ["amazon"]

  # 一つ以上の name と values のペアで検索条件を設定
  filter {
    # 検索する属性を選択
    # AWS で公開されているイメージの名称から filter
    name = "name"

    # イメージ名称のうち、以下にマッチするものを抽出
    # [*] は、ワイルドカード
    values = ["al2023-ami-*-kernel-6.1-arm64"]
  }
}
