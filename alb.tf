resource "aws_security_group" "alb" {
  name        = "Allow endusers"
  description = "Allow endusers inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "abl for endusers"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }  

   ingress {
    description      = "endusers from admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  =[aws_security_group.bastion.id]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "dev_alb_sg"
  }
} 
  #create alb ec2


  resource "aws_instance" "alb" {
  ami           = "ami-01216e7612243e0ef"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1[0].id
  security_groups  =[aws_security_group.alb.id]

  
  tags = {
    Name = "Dev-alb"
  }
}

