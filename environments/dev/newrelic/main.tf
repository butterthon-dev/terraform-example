# ########################################################
module "newrelic_cloud_integration_aws" {
  source = "../../../modules/new-relic/cloud-integration/aws"

  service_name            = "rmd"
  env                     = "dev"
  new_relic_account_id    = var.NEW_RELIC_ACCOUNT_ID
  new_relic_api_key       = var.NEW_RELIC_API_KEY
  aws_account_id          = var.AWS_ACCOUNT_ID
  new_relic_account_name  = var.NEW_RELIC_ACCOUNT_NAME
  newrelic_account_region = "US"
}
# ########################################################
