variable "cluster_type" {}

variable "path_in_consul" {
  default   = "test/master/aws"
}

variable "path_in_consul_spark" {
  default   = "test/master/spark"
}

variable "consul_server" {
  default   = "127.0.0.1"
}

variable "consul_port" {
  default   = "8500"
}

variable "datacenter" {
  default   = "dc1"
}

data "consul_keys" "app" {
  key {
    name    = "region"
    path    = "${var.path_in_consul}/region"
  }
  key {
    name    = "path_to_generated_aws_properties"
    path    = "${var.path_in_consul}/path_to_generated_aws_properties"
  }
  key {
    name    = "cidr_blocks"
    path    = "${var.path_in_consul}/route_table_cidr_block_all"
  }
}

data "consul_keys" "aws" {
  key {
    name    = "vpc_id"
    path    = "${local.path_to_generated_aws_properties}/vpc_id"
  }

  key {
    name    = "security_group"
    path    = "${local.path_to_generated_aws_properties}/default_security_group_id"
  }
  key {
    name    = "availability_zone"
    path    = "${local.path_to_generated_aws_properties}/availability_zone"
  }
  key {
    name    = "subnet_id"
    path    = "${local.path_to_generated_aws_properties}/subnet_id"
  }
}

data "consul_keys" "spark" {
  key {
    name    = "ami"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/ami"
  }
  key {
    name    = "no_workers"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/no_workers"
  }

  key {
    name    = "instance_type_master"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/instance_type_master"
  }

  key {
    name    = "instance_type_worker"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/instance_type_worker"
  }

  key {
    name    = "instance_tag"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/instance_tag"
  }
}
