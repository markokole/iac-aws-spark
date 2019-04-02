output "instance_id" {
  value = "${aws_instance.test_instance.*.id}"
}

output "public_ip" {
  value = "${aws_instance.test_instance.*.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.test_instance.*.public_dns}"
}

output "private_dns" {
  value = "${aws_instance.test_instance.*.private_dns}"
}

output "spark_history_server" {
  value = "${aws_instance.test_instance.*.public_ip[0]}:18080"
}
