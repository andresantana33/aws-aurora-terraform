data "aws_availability_zones" "available" {}

data "aws_partition" "current" {}

locals {
  env        = terraform.workspace
  vpc_name   = "default"
  vpc_id     = "vpc-026d706dad61955c6"
  subnet_ids = ["subnet-07fb304aff8b74abd", "subnet-0b6d08fe3e790091d"]
  tags = {
    env = local.env
  }
 
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "data" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    "${local.env}/tier" = "data"
  }
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "16.1"
}

resource "aws_db_subnet_group" "data" {
  name        = "db-subnet-group"
  subnet_ids  = data.aws_subnets.data.ids
  description = "Subnet group for Aurora PostgreSQL"
}

#-------------------
# Module - Aurora
#-------------------
module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"

  for_each = var.db_config

  name              = each.value.name
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = each.value.engine_mode
  engine_version    = data.aws_rds_engine_version.postgresql.version
  master_username   = each.value.master_username
  storage_encrypted = each.value.storage_encrypted

  vpc_id               = data.aws_vpc.selected.id
  db_subnet_group_name = aws_db_subnet_group.data.id
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = [data.aws_vpc.selected.cidr_block]
    }
  }

  monitoring_interval          = each.value.monitoring_interval
  skip_final_snapshot          = each.value.skip_final_snapshot
  apply_immediately            = each.value.apply_immediately
  performance_insights_enabled = each.value.performance_insights_enabled

  serverlessv2_scaling_configuration = {
    auto_pause               = each.value.auto_pause
    min_capacity             = each.value.min_capacity
    max_capacity             = each.value.max_capacity
    seconds_until_auto_pause = each.value.seconds_until_auto_pause
  }

  instance_class = each.value.instance_class
  instances = {
    instance-1 = {availability_zone="us-east-1"}
    
  }
}

