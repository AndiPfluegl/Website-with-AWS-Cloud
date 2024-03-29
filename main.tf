# Provider configuration for AWS, specifying the region to deploy resources:
provider "aws" {
  region = var.region #variable from variables.tf
}

# Security group definition to allow HTTP and HTTPS traffic to the web server:
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS"

  # Rule to allow HTTP traffic:
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule to allow HTTPS traffic:
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule to allow all outbound traffic:
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch configuration for EC2 instances, including the instance type, AMI, and user data script:
resource "aws_launch_configuration" "web_lc" {
  name            = "web-lc"
  image_id        = var.ami_id #variable from variables.tf
  instance_type   = var.instance_type #variable from variables.tf
  security_groups = [aws_security_group.web_sg.id] #variable from variables.tf

  # User data script to install and start the web server, and deploy the initial web page:
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd.service
                systemctl enable httpd.service
                echo '<html><head><title>Welcome</title></head><body><h1>Hello World!</h1></body></html>' > /var/www/html/index.html
                EOF

  # Ensures that a new launch configuration is created before the old one is destroyed during updates:
  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group definition to manage the scaling of the web server instance:
resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = var.vpc_subnets #variable from variables.tf
  target_group_arns    = [aws_lb_target_group.web_tg.arn]

  # Tags applied to each instance in the autoscaling group:
  tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
  }
}

# Target tracking autoscaling policy to adjust the number of instances based on CPU utilization:
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  # Configuration for targeting a specific CPU utilization threshold:
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.target_cpu_utilization #variable from variables.tf
  }
}

# Application Load Balancer (ALB) configuration to distribute incoming traffic across multiple targets:
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.vpc_subnets #variable from variables.tf

  # Option to prevent accidental deletion of the load balancer.
  enable_deletion_protection = false
}

# Target group for the ALB, specifying the protocol and port for incoming traffic:
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-08b332cd75cd7956e"
}

# Listener for the ALB to forward traffic to the target group:
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}


# Configuration for an AWS CloudFront distribution to deliver the web content globally:
resource "aws_cloudfront_distribution" "web_distribution" {
  # Ensures CloudFront distribution is created after the ALB listener is ready:
  depends_on = [aws_lb_listener.front_end]

  # Configuration for the ALB of the CloudFront distribution:
  origin {
    domain_name = aws_lb.web_alb.dns_name
    origin_id   = "WebPageCloudFront"

    # Configuration for how CloudFront communicates with the origin:
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true  # Enables the CloudFront distribution:

  # Configuration for the default cache behavior of the distribution:
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]  # HTTP methods CloudFront processes and forwards to the origin.
    cached_methods   = ["GET", "HEAD"]  # HTTP methods CloudFront caches responses to.
    target_origin_id = "WebPageCloudFront"

    # Configuration for forwarding request headers and cookies to the origin:
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"  # Redirects HTTP requests to HTTPS.
    min_ttl                = 0                    # The minimum amount of time CloudFront caches responses (0 seconds).
    default_ttl            = 3600                 # The default amount of time CloudFront caches responses (1 hour).
    max_ttl                = 86400                # The maximum amount of time CloudFront caches responses (24 hours).
  }

  price_class = "PriceClass_All"  # Selects the price class for the CloudFront distribution.

  # Configuration for restricting access to the distribution based on geographic location.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Configuration for the SSL certificate used by CloudFront.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}