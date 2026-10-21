module "data" {
  source = "../../data"

  allowed_security_group_ids        = [module.workloads.app_security_group_id]
  db_password                       = var.db_password
  enable_multi_az                   = var.enable_multi_az
  environment                       = var.environment
  kms_key_arn                       = module.foundation.kms_key_arn
  name_prefix                       = var.name_prefix
  postgres_engine_version           = var.postgres_engine_version
  postgres_instance_class           = var.postgres_instance_class
  private_subnet_ids                = module.network.private_subnet_ids
  redis_auth_token                  = var.redis_auth_token
  redis_engine_version              = var.redis_engine_version
  redis_node_type                   = var.redis_node_type
  redis_num_cache_clusters          = var.redis_num_cache_clusters
  vpc_id                            = module.network.vpc_id
}

module "edge" {
  source = "../../edge"

  environment       = var.environment
  name_prefix       = var.name_prefix
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
}

module "foundation" {
  source = "../../foundation"

  audit_bucket_name = var.audit_bucket_name
  environment       = var.environment
  name_prefix       = var.name_prefix
}

module "network" {
  source = "../../network"

  environment = var.environment
  name_prefix = var.name_prefix
}

module "observability" {
  source = "../../observability"

  alb_arn_suffix             = module.edge.alb_arn_suffix
  enable_slack_notifications = var.enable_slack_notifications
  environment                = var.environment
  kms_key_arn                = module.foundation.kms_key_arn
  name_prefix                = var.name_prefix
  slack_webhook_url          = var.slack_webhook_url
}

module "workloads" {
  source = "../../workloads"

  environment = var.environment
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
}
