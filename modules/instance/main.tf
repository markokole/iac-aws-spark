provider "aws" {
  region = "${local.region}"
}

locals {
  path_to_generated_aws_properties = "${var.path_in_consul}/${data.consul_keys.app.var.path_to_generated_aws_properties}"

  #app
  region               = "${data.consul_keys.app.var.region}"
  cidr_blocks          = "${data.consul_keys.app.var.cidr_blocks}"

  #aws
  vpc_id               = "${data.consul_keys.aws.var.vpc_id}"
  subnet_id            = "${data.consul_keys.aws.var.subnet_id}"
  availability_zone    = "${data.consul_keys.aws.var.availability_zone}"
  key_pair             = "${data.consul_keys.aws.var.key_pair}"

  # spark
  #ami                  = "ami-0eb0892f46a18e1de"
  ami                  = "${data.consul_keys.spark.var.ami}"
  no_workers           = "${data.consul_keys.spark.var.no_workers}" # number of workers in the cluster
  no_instances         = "${local.no_workers + 1}" # number of all nodes in the cluster
  instance_type_master = "${data.consul_keys.spark.var.instance_type_master}"
  instance_type_worker = "${data.consul_keys.spark.var.instance_type_worker}"
  instance_tag         = "${data.consul_keys.spark.var.instance_tag}"


  security_groups      = ["${aws_security_group.sg_spark_terraform.id}"]

}

resource "aws_instance" "spark_master" {
  depends_on = ["aws_security_group.sg_spark_terraform"]

  count = "1"
  ami = "${local.ami}"
  instance_type = "${local.instance_type_master}"
  subnet_id = "${local.subnet_id}"
  security_groups = ["${local.security_groups}"]
  availability_zone = "${local.availability_zone}"
  key_name = "${local.key_pair}"
  associate_public_ip_address = "true"
  tags {
    Name = "spark-master-${local.instance_tag}"
  }
  volume_tags {
    Name = "spark-master-volume-${local.instance_tag}"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = "true"
  }
}

resource "aws_instance" "spark_worker" {
  depends_on = ["aws_security_group.sg_spark_terraform"]

  count = "${local.no_workers}"
  ami = "${local.ami}"
  instance_type = "${local.instance_type_worker}"
  subnet_id = "${local.subnet_id}"
  security_groups = ["${local.security_groups}"]
  availability_zone = "${local.availability_zone}"
  key_name = "${local.key_pair}"
  associate_public_ip_address = "true"
  tags {
    Name = "spark-worker-${local.instance_tag}-${format("%02d", count.index + 1)}"
  }
  volume_tags {
    Name = "spark-worker-volume-${local.instance_tag}-${format("%02d", count.index + 1)}"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = "true"
  }
}
