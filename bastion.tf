#create bastion_sg

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "bastion" {
  name        = "Allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh from admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
} 

#create ec2 


resource "aws_instance" "bastion" {
  ami           = "ami-01216e7612243e0ef"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1[0].id
  security_groups  =[aws_security_group.bastion.id]




  tags = {
    Name = "dev-bastion"
    terraform = "true"
  }
}

