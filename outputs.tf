output "weather_api_url" {
  description = "HTTPie command to access weather API"
  value       = "http  ${local.external_loadbalancer}/weather?city=melbourne 'Host: api.powerhour.com' 'Authorization: Bearer '"
}
output "helloworld_api_url" {
  description = "HTTPie command to access helloworld API"
  value       = "http  ${local.external_loadbalancer}/helloworld 'Host: api.powerhour.com' 'Authorization: Bearer '"
}
output "grafana_dashboar_url" {
  description = "URL for Grafana Dashboard "
  value       = "http://${local.grafana_dashboard_url}:3000"
}

output "target_api_url" {
  description = "HTTPie command to access Target API"
  value       = "http  ${local.external_loadbalancer}/target 'Host: api.powerhour.com' 'Authorization: Bearer '"
}
