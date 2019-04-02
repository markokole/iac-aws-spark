# populate the template file with variables
data "template_file" "ansible_inventory_single" {
  template = "${file("${path.module}/resources/templates/ansible_inventory_single.yml.tmpl")}"
  vars {
    spark_master_name = "${local.spark_master_name}"
    spark_master_host = "${local.spark_master_host}"
    spark_slave_name = "${local.spark_slave_name}"
    spark_slave_host = "${local.spark_slave_host}"
  }
}

# create the yaml file based on template and the input values
resource "local_file" "ansible_inventory_single_render" {
  content  = "${data.template_file.ansible_inventory_single.rendered}"
  filename = "${local.workdir}/ansible-hosts"
}
