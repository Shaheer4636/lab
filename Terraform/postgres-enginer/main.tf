provider "aws" {
  region = "us-east-2"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "ak-test-public-db-lm-subnet-group"
  subnet_ids = [
    "subnet-06ff4248eaae65380",
    "subnet-005b294f31a7f312d6"
  ]

  tags = {
    Name    = "aurora-subnet-group"
    project = "5-apps"
    request = "AK"
    managed = "Ayo"
  }
}

resource "aws_rds_cluster" "aurora_postgres" {
  count                  = 3
  cluster_identifier     = "aurora-cluster-${element(["dsna", "dsnc", "dsnw"], count.index)}"
  engine                 = "aurora-postgresql"
  engine_version         = "16.8"
  master_username        = "admin"
  master_password        = "SuperSecurePassword123!"
  database_name          = upper(element(["dsna", "dsnc", "dsnw"], count.index))
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = ["sg-0691fd3403a7e5577"]
  skip_final_snapshot    = true
  publicly_accessible    = true

  tags = {
    Name    = "aurora-${element(["dsna", "dsnc", "dsnw"], count.index)}"
    project = "5-apps"
    request = "AK"
    managed = "Ayo"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 3
  identifier         = "aurora-instance-${element(["dsna", "dsnc", "dsnw"], count.index)}"
  cluster_identifier = aws_rds_cluster.aurora_postgres[count.index].id
  instance_class     = "db.t3.large"
  engine             = "aurora-postgresql"
  publicly_accessible = true

  tags = {
    Name    = "aurora-instance-${element(["dsna", "dsnc", "dsnw"], count.index)}"
    project = "5-apps"
    request = "AK"
    managed = "Ayo"
  }
}
