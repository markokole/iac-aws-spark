#output "instance_id" {
#  value = "${aws_instance.spark_master.*.id}"
#}

#output "public_dns" {
#  value = "${aws_instance.spark_master.*.public_dns}"
#}

output "master_public_ip" {
  value = "${aws_instance.spark_master.public_ip}"
}

output "master_private_dns" {
  value = "${aws_instance.spark_master.private_dns}"
}

output "worker_public_ip" {
  value = "${aws_instance.spark_worker.*.public_ip}"
}

output "worker_private_dns" {
  value = "${aws_instance.spark_worker.*.private_dns}"
}

output "spark_history_server" {
  value = "${aws_instance.spark_master.public_ip}:18080"
}

output "spark_master" {
  value = "${aws_instance.spark_master.public_ip}:8080"
}
