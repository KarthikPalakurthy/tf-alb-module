resource "aws_security_group" "alb" {

  name        = "${var.env}-alb-${var.subnet_name}security-group"
  description = "${var.env}-alb-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-alb-security-group"}
  )
}

resource "aws_lb" "test" {
  name               = "${var.env}-alb-${var.subnet_name}-alb"
  internal           = var.internal
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids


  tags = merge(
    local.common_tags,
    { Name = "${var.env}-alb"}
  )
}