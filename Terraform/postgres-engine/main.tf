provider "aws" {
  region = "us-east-2"
}

locals {
  db_names = ["dsna", "dsnc", "dsnw"]
}

resource "aws_rds_cluster" "aurora_postgres" {
  count                  = length(local.db_names)
  cluster_identifier     = "aurora-cluster-${local.db_names[count.index]}"
  engine                 = "aurora-postgresql"
  engine_version         = "16.8"
  master_username        = "admin"
  master_password        = "SuperSecurePassword123!"
  database_name          = upper(local.db_names[count.index])
  db_subnet_group_name   = "ak-test-public-db-lm-subnet-group"
  vpc_security_group_ids = ["sg-0691fd3403a7e5577"]
  skip_final_snapshot    = true

  tags = {
    Name    = "aurora-${local.db_names[count.index]}"
    project = "5-apps"
    request = "AK"
    managed = "Ayo"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count                = length(local.db_names)
  identifier           = "aurora-instance-${local.db_names[count.index]}"
  cluster_identifier   = aws_rds_cluster.aurora_postgres[count.index].id
  instance_class       = "db.t3.large"
  engine               = "aurora-postgresql"
  publicly_accessible  = true

  tags = {
    Name    = "aurora-instance-${local.db_names[count.index]}"
    project = "5-apps"
    request = "AK"
    managed = "Ayo"
  }
}
