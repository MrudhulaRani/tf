output "public_ip" {
  value = "${aws_instance.vm_tf.public_ip}"
}
output "vm" {
  value = "${aws_instance.vm_tf.id}"
}