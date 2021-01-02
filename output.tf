output "public_dns_zone_id" {
  value = module.dns_zone.public_dns_zone_id
}

output "public_dns_name_servers" {
  value = module.dns_zone.public_dns_name_servers
}

output "private_dns_zone_id" {
  value = module.dns_zone.private_dns_zone_id
}

output "private_dns_name_servers" {
  value = module.dns_zone.private_dns_name_servers
}
