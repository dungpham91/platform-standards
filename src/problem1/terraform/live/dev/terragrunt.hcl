include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules/stack/regional"
}

inputs = {
  audit_bucket_name = "devopslite-trading-dev-audit-UNIQUE_SUFFIX"
  cost_center       = "CC-DEVOPS-DEV"
  db_password       = get_env("TF_VAR_db_password")
  redis_auth_token  = get_env("TF_VAR_redis_auth_token")
  environment       = "dev"

  enable_multi_az            = false
  enable_slack_notifications = false

  postgres_engine_version  = "15.8"
  postgres_instance_class = "db.t4g.micro"
  redis_engine_version     = "7.1"
  redis_node_type          = "cache.t4g.micro"
  redis_num_cache_clusters = 1

  slack_webhook_url = get_env("TF_VAR_slack_webhook_url", "")
}
