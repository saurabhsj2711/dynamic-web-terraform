variable "access_key" {
  type = string
  default = "AKIAVMQCDUHO4XE2GBP7"
}

variable "secret_key" {
  type = string
  default = "hmQ3+AV81Z8AyCEBNMpmEz3x7Sg+D8f3WD2OHTDP"
}

variable "vpc_name" {
  type = string
  default = "webapp-vpc"
}

variable "subnet1-name"{
    type = string
    default = "webapp-subnet-public-1"
}

variable "subnet2-name"{
    type = string
    default = "webapp-subnet-private-1"
}

variable "subnet3-name"{
    type = string
    default = "webapp-subnet-public-2"
}

variable "subnet4-name"{
    type = string
    default = "webapp-subnet-private-2"
}

variable "igw-name"{
    type = string
    default = "webapp-igw"
}

variable "nat-pip-name" {
  type = string
  default = "webapp-nat-pip"
}

variable "nat-name" {
  type = string
  default = "webapp-nat"
}

variable "public-rt-name" {
  type = string
  default = "webapp-public-rt"
}

variable "private-rt-name" {
  type = string
  default = "webapp-private-rt"
}

variable "sg-name" {
  type = string
  default = "webapp-sg"
}

variable "lb-tg-name" {
  type = string
  default = "webapp-lb-tg"
}

# variable "public-subnets" {
#   type = list(string)
#   default = []
# }

variable "lb-name" {
  type = string
  default = "webapp-lb"
}

variable "image-id" {
  type = string
  default = "ami-0ecb62995f68bb549"
}

variable "instance-type" {
  type = string
  default = "t2.micro"
}

variable "webapp-launch-template" {
  type = string
  default = "webapp-template"
}

variable "autoscaling-group" {
  type = string
  default = "webapp-asg"
}