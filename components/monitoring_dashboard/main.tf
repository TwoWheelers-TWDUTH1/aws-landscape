terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}


data "terraform_remote_state" "training_kafka" {
  backend = "s3"
  config {
    key    = "training_kafka.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
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

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "2wheelers-${var.cohort}"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "System/Linux", "MemoryUtilization", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", { "label": "MemoryUtilization", "color": "#ff7f0e" } ],
                    [ ".", "DiskSpaceUtilization", "MountPath", "/", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", "Filesystem", "/dev/xvda1", { "label": "DiskSpaceUtilization", "color": "#1f77b4" } ],
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", { "color": "#2ca02c", "yAxis": "left" } ]
                ],
                "view": "singleValue",
                "region": "${var.aws_region}",
                "title": "Kafka",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 3,
            "width": 12,
            "height": 9,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "HDFSUtilization", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", { "color": "#1f77b4" } ],
                    [ ".", "AppsRunning", ".", ".", { "color": "#2ca02c" } ],
                    [ ".", "AppsPending", ".", ".", { "color": "#ff7f0e" } ],
                    [ ".", "YARNMemoryAvailablePercentage", ".", ".", { "color": "#d62728" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 300,
                "title": "EMR HDFS",
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ { "expression": "m5+m6", "label": "MemoryUsed", "id": "e1", "color": "#d62728", "region": "${var.aws_region}" } ],
                    [ "AWS/ElasticMapReduce", "MemoryAllocatedMB", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", { "id": "m4" } ],
                    [ ".", "MemoryReservedMB", ".", ".", { "id": "m5" } ],
                    [ ".", "MemoryTotalMB", ".", ".", { "id": "m6", "color": "#9467bd" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 300,
                "title": "EMR Cluster Memory Usage",
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "System/Linux", "DiskSpaceUtilization", "MountPath", "/", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", "Filesystem", "/dev/xvda1", { "label": "DiskSpaceUtilization", "color": "#1f77b4" } ],
                    [ ".", "MemoryUtilization", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", { "color": "#ff7f0e", "label": "MemoryUtilization" } ],
                    [ "AWS/EC2", "CPUUtilization", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "title": "Kafka Status",
                "period": 300,
                "yAxis": {
                    "left": {
                        "max": 100,
                        "min": 0
                    }
                },
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 9,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "AppsRunning", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", { "color": "#2ca02c" } ],
                    [ ".", "AppsPending", ".", ".", { "color": "#ff7f0e" } ],
                    [ ".", "ContainerReserved", ".", ".", { "color": "#1f77b4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 12,
            "width": 12,
            "height": 3,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "System/Linux", "MemoryUtilization", "InstanceId", "${data.terraform_remote_state.ingester.ingester_instance_id}" ]
                ],
                "region": "${var.aws_region}",
                "title": "Ingester Memory Usage",
                "period": 300,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 100
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 15,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "stationMart-monitoring", "station-last-updated-age", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "title": "Delivery File's Age",
                "yAxis": {
                    "left": {
                        "label": "Seconds",
                        "showUnits": false
                    },
                    "right": {
                        "label": "",
                        "showUnits": true
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 15,
            "width": 6,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "metrics": [
                    [ "stationMart-monitoring", "station-last-updated-age", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ]
                ],
                "title": "Station Last Updated Age (Median)",
                "start": "-PT12H",
                "end": "P0D"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 18,
            "width": 12,
            "height": 9,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "is_app_running", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationDataSFSaverApp", { "label": "StationDataSFSaverApp" } ],
                    [ "...", "StationInformationSaverApp", { "label": "StationInformationSaverApp" } ],
                    [ "...", "StationApp" ],
                    [ "...", "StationTransformerNYC"],
                    [ "...", "StationStatusSaverApp", { "label": "StationStatusSaverApp" } ],
                    [ "ingester-monitoring", ".", "ApplicationName", "StationSFIngester", "InstanceId", "${data.terraform_remote_state.ingester.ingester_instance_id}", { "label": "StationSFIngester" } ],
                    [ "...", "StationStatusIngester", ".", ".", { "label": "StationStatusIngester" } ],
                    [ "...", "StationInformationIngester", ".", ".", { "label": "StationInformationIngester" } ],
                    [ "...", "StationInformationIngesterMsk", ".", ".", { "label": "StationInformationIngesterMsk" } ],
                    [ "...", "StationStatusIngesterMsk", ".", ".", { "label": "StationStatusIngesterMsk" } ],
                    [ "...", "StationSFIngesterMsk", ".", ".", { "label": "StationSFIngesterMsk" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "${var.aws_region}",
                "title": "Application Status History",
                "period": 300,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 15,
                        "label": "is_app_running",
                        "showUnits": false
                    }
                },
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 15,
            "width": 12,
            "height": 12,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "is_app_running", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationDataSFSaverApp", { "label": "StationDataSFSaverApp" } ],
                    [ "...", "StationInformationSaverApp", { "label": "StationInformationSaverApp" } ],
                    [ "...", "StationApp" ],
                    [ "...", "StationTransformerNYC"],
                    [ "...", "StationStatusSaverApp", { "label": "StationStatusSaverApp" } ],
                    [ "ingester-monitoring", ".", "ApplicationName", "StationSFIngester", "InstanceId", "${data.terraform_remote_state.ingester.ingester_instance_id}", { "label": "StationSFIngester" } ],
                    [ "...", "StationStatusIngester", ".", ".", { "label": "StationStatusIngester" } ],
                    [ "...", "StationInformationIngester", ".", ".", { "label": "StationInformationIngester" } ],
                    [ "...", "StationInformationIngesterMsk", ".", ".", { "label": "StationInformationIngesterMsk" } ],
                    [ "...", "StationStatusIngesterMsk", ".", ".", { "label": "StationStatusIngesterMsk" } ],
                    [ "...", "StationSFIngesterMsk", ".", ".", { "label": "StationSFIngesterMsk" } ]
                ],
                "view": "singleValue",
                "stacked": true,
                "region": "${var.aws_region}",
                "title": "Application Status",
                "period": 300,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "max": 15,
                        "label": "is_app_running",
                        "showUnits": false
                    }
                },
                "stat": "Average"
            }
        }
    ]
}
 EOF
}

resource "aws_cloudwatch_dashboard" "data_dashboard" {
  dashboard_name = "2wheelers-data_${var.cohort}"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "numberOfInputRows", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationDataSFSaverApp" ],
                    [ ".", "task.recordsWritten", ".", ".", ".", ".", { "stat": "SampleCount" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Sum",
                "period": 300,
                "title": "SF-StationDataSaver-Input Rows"
            }
        },
        {
            "type": "metric",
            "x": 3,
            "y": 0,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "numberOfInputRows", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationInformationSaverApp", { "stat": "Sum" } ],
                    [ ".", "task.recordsWritten", ".", ".", ".", "." ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "SampleCount",
                "period": 300,
                "title": "NYC-StationInformationSaver-Input Rows"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "numberOfInputRows", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationStatusSaverApp" ],
                    [ ".", "task.recordsWritten", ".", ".", ".", ".", { "stat": "SampleCount" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Sum",
                "period": 300,
                "title": "NYC-StationStatusSaver-Input Rows"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationDataSFSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "title": "SF-StationDataSaver-Row Processing"
            }
        },
        {
            "type": "metric",
            "x": 3,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationInformationSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "title": "NYC-StationInformationSaver-Row Processing"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", "ApplicationName", "StationStatusSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "title": "NYC-StationStatusSaver-Row Processing"
            }
        }
    ]
}

{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "j-217L1IWLFAV67", "ApplicationName", "StationDataSFSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "ap-southeast-1",
                "stat": "Average",
                "period": 300,
                "title": "SF-StationDataSaver-Row Processing"
            }
        },
        {
            "type": "metric",
            "x": 3,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "j-217L1IWLFAV67", "ApplicationName", "StationInformationSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "ap-southeast-1",
                "stat": "Average",
                "period": 300,
                "title": "NYC-StationInformationSaver-Row Processing"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ElasticMapReduce", "inputRowsPerSecond", "JobFlowId", "j-217L1IWLFAV67", "ApplicationName", "StationStatusSaverApp", { "id": "m1", "stat": "SampleCount", "color": "#2ca02c" } ],
                    [ ".", "processedRowsPerSecond", ".", ".", ".", ".", { "id": "m2", "stat": "SampleCount", "color": "#d62728" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "ap-southeast-1",
                "stat": "Average",
                "period": 300,
                "title": "NYC-StationStatusSaver-Row Processing"
            }
        },
    ]
}


 EOF
}
