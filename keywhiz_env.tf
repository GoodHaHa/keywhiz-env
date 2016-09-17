provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "default" {
    cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${var.public_key}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
    name = "keywhiz_example"
    description = "Used in the keywhiz"
    vpc_id      = "${aws_vpc.default.id}"

    # SSH access from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Access keywhiz serverfrom anywhere
     ingress {
         from_port = 4444
         to_port = 4444
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
     }

    # HTTP access from anywhere
#    ingress {
#        from_port = 80
#        to_port = 80
#        protocol = "tcp"
#        cidr_blocks = ["0.0.0.0/0"]
#    }

    # outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "example" {
  ami           = "ami-48db9d28"
  instance_type = "t2.nano"
  key_name = "deployer-key"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  depends_on = ["aws_route.internet_access", "aws_internet_gateway.default", "aws_subnet.default"]
  connection {
      user = "ubuntu"
      type = "ssh"
      private_key = "~/.ssh/id_rsa"
  }
  provisioner "remote-exec" {
    script = "provisioning/docker.sh"
  }
}
