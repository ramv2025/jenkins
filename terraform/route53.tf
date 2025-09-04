resource "aws_route53_record" "jenkins_dns_record" {
  zone_id = data.aws_route53_zone.stg_helios_domain.zone_id
  name    = "jenkins.stg.helios.io"  # Your desired DNS name
  type    = "A"

  alias {
    name                   = aws_lb.jenkins_alb.dns_name
    zone_id                = aws_lb.jenkins_alb.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "stg_helios_domain" {
  name         = "stg.helios.io."  # Your domain name
  private_zone = false
}