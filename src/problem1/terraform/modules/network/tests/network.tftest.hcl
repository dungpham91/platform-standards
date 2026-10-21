mock_provider "aws" {}

run "network_plan" {
  command = plan

  module {
    source = "../"
  }

  variables {
    environment = "dev"
    name_prefix = "platform-mock"
  }
}
