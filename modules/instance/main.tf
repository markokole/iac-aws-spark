provider "aws" {
  region = "${local.region}"
}

locals {
  path_to_generated_aws_properties = "${var.path_in_consul}/${data.consul_keys.app.var.path_to_generated_aws_properties}"

  region = "${data.consul_keys.app.var.region}"
  ami = "${data.consul_keys.app.var.ami}"
  instance_type = "t2.micro" #"${data.consul_keys.app.var.instance_type}"
  vpc_id = "${data.consul_keys.aws.var.vpc_id}"
  subnet_id = "${data.consul_keys.aws.var.subnet_id}"
  security_groups = ["${aws_security_group.sg_spark_terraform.id}"]
  availability_zone = "${data.consul_keys.aws.var.availability_zone}"
  cidr_blocks = "${data.consul_keys.app.var.cidr_blocks}"
}

resource "aws_instance" "test_instance" {
  depends_on = ["aws_security_group.sg_spark_terraform"]

  count = "1" #"${local.no_instances}"
  ami = "${local.ami}"
  instance_type = "${local.instance_type}"
  subnet_id = "${local.subnet_id}"
  security_groups = ["${local.security_groups}"]
  availability_zone = "${local.availability_zone}"
  key_name = "mykeypair"
  associate_public_ip_address = "true"
  tags {
    Name = "spark-single"
  }
  volume_tags {
    Name = "spark-volume"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = "true"
  }
}
