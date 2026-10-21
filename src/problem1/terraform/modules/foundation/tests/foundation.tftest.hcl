mock_provider "aws" {}

run "foundation_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    audit_bucket_name = "devopslite-mock-audit-bucket-001"
    environment       = "dev"
    name_prefix       = "devopslite-mock"
  }
}
