mock_provider "aws" {}

run "observability_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    environment = "dev"
    kms_key_arn = "arn:aws:kms:ap-southeast-1:123456789012:key/00000000-0000-0000-0000-000000000001"
    name_prefix = "devopslite-mock"
  }
}
