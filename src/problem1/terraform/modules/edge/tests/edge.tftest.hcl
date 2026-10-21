mock_provider "aws" {}

run "edge_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    environment       = "dev"
    name_prefix       = "platform-mock"
    vpc_id            = "vpc-0123456789abcdef0"
    public_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }
}
