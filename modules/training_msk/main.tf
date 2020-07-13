resource "aws_security_group" "sg" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "everything"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_msk_cluster" "training_msk" {
  cluster_name           = "${var.deployment_identifier}"
  kafka_version          = "1.1.1"
  number_of_broker_nodes = 3
  enhanced_monitoring = "PER_TOPIC_PER_BROKER"

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
    }
  }

  broker_node_group_info {
    instance_type   = "${var.instance_type}"
    ebs_volume_size = 100
    client_subnets = ["${var.client_subnets}"]
    security_groups = ["${aws_security_group.sg.id}"]
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
}