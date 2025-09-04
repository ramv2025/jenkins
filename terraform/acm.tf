resource "aws_acm_certificate" "jenkins" {
  domain_name       = "jenkins.stg.helios.com"
  validation_method = "DNS"

  tags = {
    Name = "jenkins-cert"
  }
}