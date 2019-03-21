resource "aws_vpc" "vpc_tf" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name="vpc_${var.project}"
  }
  }

resource "aws_internet_gateway" "igw_tf" {
  vpc_id = "${aws_vpc.vpc_tf.id}"

  tags {
    Name="igw_${var.project}"
  }
}

resource "aws_route_table" "rt_tf" {
  vpc_id = "${aws_vpc.vpc_tf.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_tf.id}"
  }
  tags {
    Name="rt_${var.project}"
  }
}

resource "aws_network_acl" "nacl-rf" {
  vpc_id = "${aws_vpc.vpc_tf.id}"
  subnet_ids = ["${aws_subnet.sn_tf.id}"]
  ingress {
    action = "allow"
    from_port = 0
    protocol = "-1"
    rule_no = 100
    to_port = 0
    cidr_block = "0.0.0.0/0"
  }
  egress {
    action = "allow"
    from_port = 0
    protocol = "-1"
    rule_no = 100
    to_port = 0
    cidr_block = "0.0.0.0/0"
  }
  tags {
    Name="nacl_${var.project}"
  }
}


resource "aws_subnet" "sn_tf" {
  cidr_block = "${var.sn_cidr}"
  vpc_id = "${aws_vpc.vpc_tf.id}"
  availability_zone = "${var.az}"
  map_public_ip_on_launch = true
  tags {
    Name = "sn_${var.project}"
  }
}

resource "aws_route_table_association" "rt_as_tf" {
  route_table_id = "${aws_route_table.rt_tf.id}"
  subnet_id = "${aws_subnet.sn_tf.id}"
}

resource "aws_security_group" "sg_tf" {
  vpc_id = "${aws_vpc.vpc_tf.id}"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags {
    Name="sg_${var.project}"
  }
}

resource "aws_instance" "vm_tf" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "cli"
  subnet_id = "${aws_subnet.sn_tf.id}"
  security_groups = ["${aws_security_group.sg_tf.id}"]
  user_data = <<-EOF
                #!/bin/bash
                yum intsall -y nginx
                service nginx start
              EOF
  tags {
    Name="vm_${var.project}"
  }
}