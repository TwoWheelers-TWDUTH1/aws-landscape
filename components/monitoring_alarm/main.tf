terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

data "terraform_remote_state" "training_emr_cluster" {
  backend = "s3"
  config {
    key    = "training_emr_cluster.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "ingester" {
  backend = "s3"
  config {
    key    = "ingester.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

resource "aws_cloudwatch_metric_alarm" "emr_station_data_sf_saver_status" {
  alarm_name          = "StationDataSFSaverAppStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ElasticMapReduce"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    JobFlowId       = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ApplicationName = "StationDataSFSaverApp"
  }
}

resource "aws_cloudwatch_metric_alarm" "emr_station_information_saver_status" {
  alarm_name          = "StationInformationSaverAppStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ElasticMapReduce"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    JobFlowId       = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ApplicationName = "StationInformationSaverApp"
  }
}

resource "aws_cloudwatch_metric_alarm" "emr_station_app_status" {
  alarm_name          = "StationAppStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ElasticMapReduce"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    JobFlowId       = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ApplicationName = "StationApp"
  }
}

resource "aws_cloudwatch_metric_alarm" "emr_station_transformer_nyc_status" {
  alarm_name          = "StationTransformerNYCStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ElasticMapReduce"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    JobFlowId       = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ApplicationName = "StationTransformerNYC"
  }
}

resource "aws_cloudwatch_metric_alarm" "emr_station_status_saver_app_status" {
  alarm_name          = "StationStatusSaverAppStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ElasticMapReduce"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    JobFlowId       = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ApplicationName = "StationStatusSaverApp"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_sf_ingester_status" {
  alarm_name          = "StationSFIngesterStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationSFIngester"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_status_ingester_status" {
  alarm_name          = "StationStatusIngesterStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationStatusIngester"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_information_ingester_status" {
  alarm_name          = "StationInformationIngesterStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationInformationIngester"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_information_ingester_msk_status" {
  alarm_name          = "StationInformationIngesterMskStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationInformationIngesterMsk"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_status_ingester_msk_status" {
  alarm_name          = "StationStatusIngesterMskStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationStatusIngesterMsk"
  }
}

resource "aws_cloudwatch_metric_alarm" "ingester_station_sf_ingester_msk_status" {
  alarm_name          = "StationSFIngesterMskStatusAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "ingester-monitoring"
  metric_name         = "is_app_running"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "false"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId      = "${data.terraform_remote_state.ingester.ingester_instance_id}"
    ApplicationName = "StationSFIngesterMsk"
  }
}
