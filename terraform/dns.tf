data "aws_route53_zone" "this" {
  name = "marshallford.me"
}

resource "aws_route53_record" "a" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = data.aws_route53_zone.this.name
  type    = "A"
  ttl     = 3600
  records = [for r in google_cloud_run_domain_mapping.apex.status[0].resource_records : r.rrdata if r.type == "A"]
}

resource "aws_route53_record" "aaaa" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = data.aws_route53_zone.this.name
  type    = "AAAA"
  ttl     = 3600
  records = [for r in google_cloud_run_domain_mapping.apex.status[0].resource_records : r.rrdata if r.type == "AAAA"]
}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = google_cloud_run_domain_mapping.www.name
  type    = "CNAME"
  ttl     = 3600
  records = [google_cloud_run_domain_mapping.www.status[0].resource_records[0].rrdata]
}
