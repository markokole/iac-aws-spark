module "provision_spark" {
  source             = "../instance"
  cluster_type       = "${var.cluster_type}"
}

locals {
  workdir="${path.cwd}/output"

  #spark_master_name = "${join(",", module.provision_spark.private_dns)}"
  #spark_master_host = "${join(",", module.provision_spark.public_ip)}"
  spark_master_name = "${module.provision_spark.private_dns[0]}"
  spark_master_host = "${module.provision_spark.public_ip[0]}"
  spark_slave_name = "${module.provision_spark.private_dns[1]}"
  spark_slave_host = "${module.provision_spark.public_ip[1]}"
}

resource "null_resource" "wait_for_infra" {
  depends_on = ["module.provision_spark"]

  provisioner "local-exec" {
    command = <<EOF
      sleep 20
EOF
  }
}

resource "null_resource" "prepare_environment" {
  #depends_on = ["module.provision_spark"]
  depends_on = ["null_resource.wait_for_infra"]

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook --inventory=${local.workdir}/ansible-hosts ${path.module}/resources/prepare_environment.yml --extra-vars \"spark_master_host=${local.spark_master_name}\""
  }
}

resource "null_resource" "configure_start_history_server" {
  depends_on = ["null_resource.prepare_environment"]

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook --inventory=${local.workdir}/ansible-hosts ${path.module}/resources/configure_start_history_server.yml"
  }
}

resource "null_resource" "start_slaves" {
  depends_on = ["null_resource.configure_start_history_server"]

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook --inventory=${local.workdir}/ansible-hosts ${path.module}/resources/start_slaves.yml --extra-vars \"spark_master_host=${local.spark_master_name}\""
  }
}
