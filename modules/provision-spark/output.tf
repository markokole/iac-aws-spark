output "spark_history_server" {
  value = "${module.provision_spark.spark_history_server}"
}

output "spark_master" {
  value = "${module.provision_spark.spark_master}"
}

output "number_of_workers" {
  value = "${local.no_workers}"
}

#output "file_execute_on_spark_cluster" {
#  value = "${local.execute_file}"
#}

#output "worker_ui" {
#  value = "${local.spark_worker_host}:8081"
#}
