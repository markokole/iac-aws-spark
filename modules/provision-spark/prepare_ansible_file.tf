data "template_file" "generate_worker_list" {
  count = "${local.no_workers}"
  template = "${file("${path.module}/resources/templates/worker_list.tmpl")}"
  vars {
    worker_text = "${element(local.spark_worker_name, count.index)} ansible_host=${element(local.spark_worker_host, count.index)} ansible_user=centos ansible_ssh_private_key_file=\"/home/centos/.ssh/id_rsa\""
  }
}

# populate the template file with variables
data "template_file" "ansible_inventory_single" {
  count = "1"
  template = "${file("${path.module}/resources/templates/ansible_inventory_single.yml.tmpl")}"
  vars {
    spark_master_name = "${local.spark_master_name}"
    spark_master_host = "${local.spark_master_host}"
    worker_text = "${join("",data.template_file.generate_worker_list.*.rendered)}"
  }
}

# create the yaml file based on template and the input values
resource "local_file" "ansible_inventory_single_render" {
  content  = "${data.template_file.ansible_inventory_single.rendered}"
  filename = "${local.workdir}/ansible-hosts"
}
