mock_provider "aws" {}

run "data_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    allowed_security_group_ids = ["sg-0123456789abcdef0"]
    db_password                = "mock-password-not-used-in-apply"
    enable_multi_az            = false
    environment                = "dev"
    kms_key_arn                = "arn:aws:kms:ap-southeast-1:123456789012:key/00000000-0000-0000-0000-000000000001"
    name_prefix                = "devopslite-mock"
    postgres_engine_version    = "15.8"
    postgres_instance_class    = "db.t4g.micro"
    private_subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    redis_auth_token           = "mock-redis-auth-token-16chars"
    redis_engine_version       = "7.1"
    redis_node_type            = "cache.t4g.micro"
    redis_num_cache_clusters   = 1
    vpc_id                     = "vpc-0123456789abcdef0"
  }
}
