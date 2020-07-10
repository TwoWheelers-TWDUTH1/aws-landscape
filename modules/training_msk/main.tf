resource "aws_security_group" "sg" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_msk_cluster" "training_msk" {
  cluster_name           = "${var.deployment_identifier}"
  kafka_version          = "1.1.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "${var.instance_type}"
    ebs_volume_size = 100
    client_subnets = ["${var.client_subnets}"]
    security_groups = ["${aws_security_group.sg.id}"]
  }
}