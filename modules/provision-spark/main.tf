module "provision_spark" {
  source       = "../instance"
  cluster_type = var.cluster_type
}

locals {
  workdir = "${path.cwd}/output"

  spark_master_name = module.provision_spark.master_private_dns
  spark_master_host = module.provision_spark.master_public_ip
  spark_worker_name = module.provision_spark.worker_private_dns
  spark_worker_host = module.provision_spark.worker_public_ip

  # spark
  no_workers     = data.consul_keys.spark.var.no_workers
  exec_path      = data.consul_keys.spark.var.exec_path
  spark_job_name = data.consul_keys.spark.var.spark_job_name
  git_repo       = data.consul_keys.spark.var.git_repo
  git_dest       = data.consul_keys.spark.var.git_dest
  class_name     = data.consul_keys.spark.var.class_name
}

resource "null_resource" "execute_spark" {
  depends_on = [module.provision_spark]

  provisioner "local-exec" {
    command = <<EOF
      sleep 20
EOF

  }

  provisioner "local-exec" {
    command = <<EOF
export ANSIBLE_HOST_KEY_CHECKING=False; \
ansible-playbook --inventory=${local.workdir}/ansible-hosts \
                 ${path.module}/resources/ansible/spark.yml \
                 --extra-vars local_workdir=${local.workdir} \
                 --extra-vars spark_master_name=${local.spark_master_name} \
                 --extra-vars git_repo=${local.git_repo} \
                 --extra-vars git_dest=${local.git_dest} \
                 --extra-vars exec_path=${local.exec_path}
EOF


  }
}

