# Terraform

**direnv**: ディレクトリ毎に.envrcに記載の環境を読み取る
sudo pacman -S direnv

タブ補完設定
$ terraform -install-autocomplete

## 基本構文

```tf
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}

やりたいこと "どの機能を利用するか" "リソース名称"
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  設定項目 = 設定内容
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```
### BLOCK TYPE について

**resource**: 作業したいものを取り扱うことを示す
**data**: 情報を定義する

aws_vpc のところは構築したいprovider(AWS, Azure)などによって異なる

```tf
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}
```

data は AWS 上にあるリソースを Terraform で利用できるよに読み込む定義

```tf
data "aws_iam_user" "my_user" {
    user_name = "my_user_name"
}
```

構築前のチェック -target でリソースを指定できる。
$ terraform plan -target=aws_vpc.vpc

構築する
$ terraform apply

構築したリソース名の確認
$ terraform state list

リソースの設定値を確認
$ terraform state show

削除前の確認
$ terraform plan -destroy

削除する
$ terraform destroy
