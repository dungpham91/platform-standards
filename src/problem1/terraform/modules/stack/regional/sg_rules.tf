resource "aws_security_group_rule" "app_to_postgres" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.workloads.app_security_group_id
  source_security_group_id = module.data.data_security_group_id
  description              = "PostgreSQL to data tier"
}

resource "aws_security_group_rule" "app_to_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.workloads.app_security_group_id
  source_security_group_id = module.data.data_security_group_id
  description              = "Redis to data tier"
}
