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
    name    = "access_key"
    path    = "${var.path_in_consul}/access_key"
    default = ""
  }

  key {
    name    = "secret_access_key"
    path    = "${var.path_in_consul}/secret_access_key"
    default = ""
  }
}

data "consul_keys" "spark" {
  key {
    name    = "no_workers"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/no_workers"
  }
  key {
    name    = "exec_path"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/exec_path"
  }
  key {
    name    = "spark_job_args"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/spark_job_args"
  }
  key {
    name    = "spark_job_name"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/spark_job_name"
  }
  key {
    name    = "git_repo"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/git_repo"
  }
  key {
    name    = "git_dest"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/git_dest"
  }
  key {
    name    = "class_name"
    path    = "${var.path_in_consul_spark}/${var.cluster_type}/class_name"
    default = ""
  }

}
