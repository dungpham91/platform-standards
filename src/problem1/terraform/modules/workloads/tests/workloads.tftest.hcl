mock_provider "aws" {}

run "workloads_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    environment = "dev"
    name_prefix = "devopslite-mock"
    vpc_id      = "vpc-0123456789abcdef0"
  }
}
