module "provision_spark" {
  source                 = "../instance"
  cluster_type           = "${var.cluster_type}"
}

locals {
  workdir                = "${path.cwd}/output"

  spark_master_name      = "${module.provision_spark.master_private_dns}"
  spark_master_host      = "${module.provision_spark.master_public_ip}"
  spark_worker_name      = "${module.provision_spark.worker_private_dns}"
  spark_worker_host      = "${module.provision_spark.worker_public_ip}"


  # spark
  no_workers             = "${data.consul_keys.spark.var.no_workers}"
  exec_path              = "${data.consul_keys.spark.var.exec_path}"
  spark_job_args         = "${data.consul_keys.spark.var.spark_job_args}"
  spark_job_name         = "${data.consul_keys.spark.var.spark_job_name}"
  git_repo               = "${data.consul_keys.spark.var.git_repo}"
  git_dest               = "${data.consul_keys.spark.var.git_dest}"

  spark_url              = "https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz"
  spark_dir              =  "/usr/spark/"
  spark_version          = "spark-2.4.0-bin-hadoop2.7"
}

resource "null_resource" "prepare_environment" {
  depends_on = ["module.provision_spark"]

  provisioner "local-exec" {
    command = <<EOF
      sleep 30
EOF
  }

  provisioner "local-exec" {
    command = <<EOF
export ANSIBLE_HOST_KEY_CHECKING=False; \
ansible-playbook --inventory=${local.workdir}/ansible-hosts \
                 ${path.module}/resources/prepare_environment.yml \
                 --extra-vars spark_master_host=${local.spark_master_name} \
                 --extra-vars spark_url=${local.spark_url} \
                 --extra-vars spark_dir=${local.spark_dir} \
                 --extra-vars spark_version=${local.spark_version}
EOF
  }
}

resource "null_resource" "configure_start_history_server" {
  depends_on = ["null_resource.prepare_environment"]

  provisioner "local-exec" {
    command = <<EOF
export ANSIBLE_HOST_KEY_CHECKING=False; \
ansible-playbook --inventory=${local.workdir}/ansible-hosts \
                 ${path.module}/resources/configure_master.yml \
                 --extra-vars spark_master_host=${local.spark_master_name} \
                 --extra-vars spark_url=${local.spark_url} \
                 --extra-vars spark_dir=${local.spark_dir} \
                 --extra-vars spark_version=${local.spark_version}
EOF
#--extra-vars @resources/vars.yml \
  }
}

resource "null_resource" "start_workers" {
  depends_on = ["null_resource.configure_start_history_server"]

  provisioner "local-exec" {
    command = <<EOF
export ANSIBLE_HOST_KEY_CHECKING=False; \
ansible-playbook --inventory=${local.workdir}/ansible-hosts \
                 ${path.module}/resources/start_workers.yml \
                 --extra-vars spark_master_host=${local.spark_master_name} \
                 --extra-vars spark_url=${local.spark_url} \
                 --extra-vars spark_dir=${local.spark_dir} \
                 --extra-vars spark_version=${local.spark_version}
EOF
  }
}

resource "null_resource" "run_python_code" {
  depends_on = ["null_resource.start_workers"]

  provisioner "local-exec" {
    command = <<EOF
      echo "SPARK HISTORY SERVER:"
      echo "${module.provision_spark.spark_history_server}"

      echo "SPARK MASTER:"
      echo "${module.provision_spark.spark_master}"

      echo "Spark job name"
      echo "${local.spark_job_name}"
EOF
  }

  provisioner "local-exec" {
    command = <<EOF
export ANSIBLE_HOST_KEY_CHECKING=False; \
ansible-playbook --inventory=${local.workdir}/ansible-hosts \
                 ${path.module}/resources/execute_on_spark/execute.yml \
                 --extra-vars spark_master_host=${local.spark_master_name} \
                 --extra-vars exec_path=${local.exec_path} \
                 --extra-vars spark_job_args="${local.spark_job_args}" \
                 --extra-vars spark_job_name="${local.spark_job_name}" \
                 --extra-vars git_repo=${local.git_repo} \
                 --extra-vars git_dest=${local.git_dest} \
                 --extra-vars spark_url=${local.spark_url} \
                 --extra-vars spark_dir=${local.spark_dir} \
                 --extra-vars spark_version=${local.spark_version}
EOF
  }
}
