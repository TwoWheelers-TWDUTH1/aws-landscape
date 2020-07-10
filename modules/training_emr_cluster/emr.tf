resource "aws_emr_cluster" "training_cluster" {
  name          = "${local.cluster_name}"
  release_label = "emr-5.15.0"
  applications = [
    "Spark", "Hue", "Hive", "Ganglia", "Pig", "Flink", "Oozie", "Zeppelin"
  ]
  log_uri = "s3://${aws_s3_bucket.emr_logs.id}/emr/"

  keep_job_flow_alive_when_no_steps = true

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  lifecycle {
    ignore_changes = ["step"]
  }

  ebs_root_volume_size = 40

  ec2_attributes {
    subnet_id                         = "${var.subnet_id}"
    emr_managed_master_security_group = "${aws_security_group.master.id}"
    emr_managed_slave_security_group  = "${aws_security_group.core.id}"
    service_access_security_group     = "${aws_security_group.service.id}"
    additional_master_security_groups = "${aws_security_group.emr_shared.id}"
    additional_slave_security_groups  = "${aws_security_group.emr_shared.id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_node.arn}"
    key_name                          = "${var.ec2_key_pair}"
  }

  service_role = "${aws_iam_role.emr_service.arn}"

  instance_group {
    instance_role  = "MASTER"
    instance_type  = "${var.master_type}"
    instance_count = "1"
  }

  instance_group {
    instance_role  = "CORE"
    instance_type  = "${var.core_type}"
    instance_count = "${var.core_count}"
    ebs_config {
      iops = "0"
      size = "500"
      type = "gp2"
    }
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", local.cluster_name
    )
  )}"
}
