data "terraform_remote_state" "training-msk" {
  backend = "s3"
  config {
    key    = "base_networking.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

module "training_msk" {
  source = "../../modules/training_msk"

  deployment_identifier     = "data-eng-${var.cohort}"
  vpc_id                    = "${data.terraform_remote_state.training-msk.vpc_id}"
  client_subnets            = ["${data.terraform_remote_state.training-msk.private_subnet_ids}"]
  instance_type             = "${var.instance_type}"
  aws_region                = "${var.aws_region}"
  cohort                    =  "${var.cohort}"
}
