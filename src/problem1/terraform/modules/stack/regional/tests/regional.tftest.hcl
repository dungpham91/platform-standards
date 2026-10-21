mock_provider "aws" {}

run "regional_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    audit_bucket_name        = "platform-mock-audit-bucket-001"
    aws_region               = "ap-southeast-1"
    cost_center              = "CC-MOCK"
    db_password              = "mock-db-password-not-used"
    enable_multi_az          = false
    environment              = "dev"
    name_prefix              = "platform-mock"
    owner                    = "platform-team"
    postgres_engine_version  = "15.8"
    postgres_instance_class  = "db.t4g.micro"
    redis_auth_token         = "mock-redis-auth-token-16chars"
    redis_engine_version     = "7.1"
    redis_node_type          = "cache.t4g.micro"
    redis_num_cache_clusters = 1
  }
}
