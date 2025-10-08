# DB Subnet Group 設定

# サブネットグループ
# RDS用のサブネットグループを設定する
# RDSが起動するAZを指定する項目

# DB 用のサブネットグループを構築
resource "aws_db_subnet_group" "db_subgrp" {
  # サブネットグループ名を設定
  name = "db-subgrp"

  # サブネットのIDを設定
  # [vpc.tf]で定義した DB 用のサブネットを参照する設定
  subnet_ids = [aws_subnet.dbsub_a.id, aws_subnet.dbsub_c.id]

  # タグ
  tags = {
    Name = "db-subnet-group"
  }
}

# RDS Parameter Group 設定

# RDS クラスター用のパラメーターグループを構築
resource "aws_rds_cluster_parameter_group" "db_clstr_pmtgrp" {
  # パラメーターグループ名を設定
  name = "db-clstr-pmtgrp"

  # クラスターのパラメータグループは、DBの種類に応じて設定可能
  # DB エンジンの種類とバージョンに応じて設定
  # 今回の構築するのは aurora-mysql3.08.2 を設定
  family = "aurora-mysql8.0"

  # このパラメータグループについての説明文
  description = "RDS Cluster Parameter Group"

  # name に指定したパラメータの設定値を決定
  # character_set_server を utf8 に設定
  parameter {
    name = "character_set_server"
    value = "utf8"
  }

  # character_set_client を utf8 に設定
  parameter {
    name = "character_set_client"
    value = "utf8"
  }

  # time_zone を Asia/Tokyo に設定
  parameter {
    name = "time_zone"
    value = "Asia/Tokyo"

    # 即時変更できるパラメータは以下の記述で即時適用できる
    apply_method = "immediate"
  }
}

# DBインスタンス用のパラメータグループを構築
resource "aws_db_parameter_group" "db_pmtgrp" {
  # パラメータグループ名を設定
  name = "db-pmtgrp"

  # RDSインスタンスのパラメーターグループは、DBの種類に応じて設定できる
  # DBエンジンの種類とバージョンに応じて設定
  family = "aurora-mysql8.0"

  description = "RDS Instance Parameter Group"
}

# DB クラスタ設定
# RDS クラスタを構築する
# DB クラスタはクラスターの中に DB インスタンスのマスター/レプリカが存在する
# クラスタ：同じようなものがあつまっている。
# あるいは、複数のコンピュータが集まって1つのコンピュータっぽく振る舞っているシステム

resource "aws_rds_cluster" "aurora_clstr" {
  # クラスタの識別子を設定
  cluster_identifier = "aurora-cluster"

  # クラスタ作成時に自動作成されるDB名を設定
  database_name = "mydb"

  # マスターDBのユーザー名を設定
  master_username = "admin"

  # マスターDBのパスワードを設定
  # これは別で管理したほうがいいと思う
  master_password = "password"

  # DBが接続を受け入れるポートを設定
  port = 3306

  # DBの変更をすぐに適用するか、次のメンテナンス期間中に適用するかを指定
  # これよくわからない
  # マネージドサービスで使われるメンテナンスウィンドウ（メンテナンスできる期間）
  # この期間内では、メンテナスが許可されており、変更内容が適用される。
  # 変更内容によってはマネージドサービスの再起動が行われる
  # true にすると、即座に変更が反映され、false は上述した通り
  apply_immediately = false

  # クラスタ削除時に最終スナップショットの作成有無を設定
  # true は skip が有効になるため、スナップショットを作成しない
  skip_final_snapshot = true

  # このクラスターで利用するデータベースのエンジンを設定
  engine = "aurora-mysql"

  # aurora-mysql のバージョンを指定
  engine_version = "8.0.mysql_aurora.3.08.2"

  # 利用するSGのIDを設定
  # [vpc_sg.tf]で定義したリソースを設定
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # 利用するDBサブネットの名称を設定
  # aws_db_subnet_group で定義したサブネットグループをクラスターに設定
  db_subnet_group_name = aws_db_subnet_group.db_subgrp.name

  # aws_db_parameter_group で定義したパラメータグループをクラスターに設定
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_clstr_pmtgrp.name

  # タグ
  tags = {
    Name = "aurora-cluster"
  }
}

# RDS Instance 設定

# RDS インスタンスを構築
resource "aws_rds_cluster_instance" "aurora_instance" {
  # 構築するインスタンスの台数を設定
  count = 2

  # RDS インスタンスの識別子を設定
  # count.index でインスタンスに対応する個別のindex番号を付与
  # インスタンス1台目は0, 2台目は1とcountに応じて増減
  identifier = "aurora-cluster-${count.index}"

  # RDS インスタンスを起動するクラスタのidを設定
  cluster_identifier = aws_rds_cluster.aurora_clstr.id

  # インスタンスのクラスを設定
  instance_class = "db.t3.medium"

  # データベースの変更をすぐに適用するか、次のメンテナス期間中に適用するか
  apply_immediately = false

  # RDS インスタンスで利用するデータベースエンジンを指定
  engine = "aurora-mysql"

  # aurora-mysql のバージョンを指定
  engine_version = "8.0.mysql_aurora.3.08.2"

  # 利用するDBサブネットの名称を設定
  # aws_db_subnet_group で定義したサブネットグループをクラスターに設定
  db_subnet_group_name = aws_db_subnet_group.db_subgrp.name

  # aws_db_parameter_group で定義したパラメータグループをクラスターに設定
  db_parameter_group_name = aws_db_parameter_group.db_pmtgrp.name

  # タグ
  tags = {
    Name = "aurora-instance"
  }
}

# RDSクラスタの書き込み用エンドポイントを出力
output "rds-endpoint" {
  value = aws_rds_cluster.aurora_clstr.endpoint
}

# RDSクラスタの読み込み用エンドポイントを出力
output "rds-endpoint-ro" {
  value = aws_rds_cluster.aurora_clstr.reader_endpoint
}
