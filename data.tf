data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags = {
    Name : "cluster-VPC"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["SUB*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}