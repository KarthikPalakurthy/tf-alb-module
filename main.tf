resource "aws_security_group" "alb" {

  name        = "${var.env}-${var.subnet_name}security-group"
  description = "${var.env}-alb-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr_blocks
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
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
  name               = "${var.env}-${var.subnet_name}-alb"
  internal           = var.internal
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids


  tags = merge(
    local.common_tags,
    { Name = "${var.env}-alb"}
  )
}


resource "aws_lb_listener" "backend" {
  count = var.internal ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not available"
      status_code  = "502"
    }
  }
}

resource "aws_route53_record" "public_lb" {
  count = var.internal ? 0 : 1
  zone_id = "Z0636942108K930OU3P3D"
  name    = var.dns_domain
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.test.dns_name]
}
