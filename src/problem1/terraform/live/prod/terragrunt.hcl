include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules/stack/regional"
}

inputs = {
  audit_bucket_name = "devopslite-trading-prod-audit-UNIQUE_SUFFIX"
  cost_center       = "CC-DEVOPS-PROD"
  db_password       = get_env("TF_VAR_db_password")
  redis_auth_token  = get_env("TF_VAR_redis_auth_token")
  environment       = "prod"

  enable_multi_az            = true
  enable_slack_notifications = true

  postgres_engine_version  = "15.8"
  postgres_instance_class  = "db.r6g.large"
  redis_engine_version     = "7.1"
  redis_node_type          = "cache.r6g.large"
  redis_num_cache_clusters = 2

  slack_webhook_url = get_env("TF_VAR_slack_webhook_url", "")
}
