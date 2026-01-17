################### networking setting #######################

## VPC creation ##
resource "aws_vpc" "webapp-vpc" {
  cidr_block = "10.10.10.0/24"
  instance_tenancy = "default"
  tags = {
    Name = var.vpc_name
  }
}

## creating 4 subnets ##
resource "aws_subnet" "webapp-subnet-public-1" {
  vpc_id = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.10.0/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet1-name
    Tier = "Public"
  }
}

resource "aws_subnet" "webapp-subnet-private-1" {
  vpc_id = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.10.64/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet2-name
  }
}

resource "aws_subnet" "webapp-subnet-public-2" {
  vpc_id = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.10.128/26"
  availability_zone = "us-east-1b"
  tags = {
    Name = var.subnet3-name
    Tier = "Public"
  }
}

resource "aws_subnet" "webapp-subnet-private-2" {
  vpc_id = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.10.192/26"
  availability_zone = "us-east-1b"
  tags = {
    Name = var.subnet4-name
  }
}

## Internet Gateway ##
resource "aws_internet_gateway" "webapp-igw" {
  vpc_id = aws_vpc.webapp-vpc.id
  tags = {
    Name = var.igw-name
  }
}

## Creating Nat Gateway - It requires elatic ip ##
resource "aws_eip" "webapp-nat-pip" {
  domain = "vpc"
  tags = {
    Name = var.nat-pip-name
  }
}

resource "aws_nat_gateway" "webapp-nat" {
  subnet_id = aws_subnet.webapp-subnet-public-1.id
  allocation_id = aws_eip.webapp-nat-pip.id
  tags = {
    Name = var.nat-name
  }
}


## Created route table for public subnets ##
resource "aws_route_table" "webapp-rt-public" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-igw.id
  }

  tags = {
    Name = var.public-rt-name
  }
}

resource "aws_route_table_association" "webapp-public-subnet-assoc-1" {
  route_table_id = aws_route_table.webapp-rt-public.id
  subnet_id = aws_subnet.webapp-subnet-public-1.id
}

resource "aws_route_table_association" "webapp-public-subnet-assoc-2" {
  route_table_id = aws_route_table.webapp-rt-public.id
  subnet_id = aws_subnet.webapp-subnet-public-2.id
}

## Created route table for private subnets ##
resource "aws_route_table" "webapp-rt-private" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.webapp-nat.id
  }

  tags = {
    Name = var.private-rt-name
  }

  depends_on = [ aws_nat_gateway.webapp-nat ]
}

resource "aws_route_table_association" "webapp-private-subnet-assoc-1"{
  route_table_id = aws_route_table.webapp-rt-private.id
  subnet_id = aws_subnet.webapp-subnet-private-1.id
}

resource "aws_route_table_association" "webapp-private-subnet-assoc-2"{
  route_table_id = aws_route_table.webapp-rt-private.id
  subnet_id = aws_subnet.webapp-subnet-private-2.id
}

################################################################################


###################### load balancer creation ##############################

resource "aws_security_group" "webapp-sg" {
  
  vpc_id = aws_vpc.webapp-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = -1
  }

  tags = {
    Name = var.sg-name
  }

}


resource "aws_lb_target_group" "webapp-lb-tg" {
  target_type = "instance"
  protocol = "HTTP"
  port = 80
  vpc_id = aws_vpc.webapp-vpc.id

  health_check {
    enabled = true
    path = "/"
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5 
  }

  tags = {
    Name = var.lb-tg-name
  }
  
}


# data "aws_vpc" "public_subnets" {

#   filter {
#     name = "vpc-id"
#     values = [aws_vpc.webapp-vpc.id]
#   }
#   filter {
#     name = "tag:tier"
#     values = [ "Public" ]
#   }
  
# }

resource "aws_lb" "webapp-lb" {
  load_balancer_type = "application"
  internal = false
  subnets = [tostring(aws_subnet.webapp-subnet-public-1.id),tostring(aws_subnet.webapp-subnet-public-2.id)]
  security_groups = [aws_security_group.webapp-sg.id]
  enable_deletion_protection = false

  tags = {
    Name = var.lb-name
  }
  depends_on = [ aws_lb_target_group.webapp-lb-tg ]
}

resource "aws_lb_listener" "webapp-lb-listener" {
  load_balancer_arn = aws_lb.webapp-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webapp-lb-tg.arn
  }
}

resource "aws_launch_template" "webapp-template" {
  
  image_id = var.image-id
  instance_type = var.instance-type
  vpc_security_group_ids = [aws_security_group.webapp-sg.id]

  user_data = filebase64("./webserver.sh")

  tags = {
    Name = var.webapp-launch-template
  }
  
}

resource "aws_autoscaling_group" "webapp-asg" {
  name = var.autoscaling-group
  desired_capacity = 2
  min_size = 2
  max_size = 2 

  launch_template {
    id = aws_launch_template.webapp-template.id
    version = aws_launch_template.webapp-template.latest_version
  }
  vpc_zone_identifier = [ aws_subnet.webapp-subnet-private-1.id ]
  target_group_arns = [ aws_lb_target_group.webapp-lb-tg.arn ]

  depends_on = [ aws_lb.webapp-lb, aws_route_table.webapp-rt-private ]

}