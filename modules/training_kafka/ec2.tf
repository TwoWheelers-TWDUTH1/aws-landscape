resource "aws_instance" "kafka" {
  ami                    = "ami-01dd36343fe7a0c8a" //${data.aws_ami.training_kafka.image_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.kafka.id}"]
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.ec2_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.kafka.name}"

  root_block_device {
    volume_size = 60
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "kafka-${var.deployment_identifier}"
    )
  )}"
}
