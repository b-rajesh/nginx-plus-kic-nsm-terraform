module "prometheus" {
  source                 = "./modules/prometheus-grafana"
  load_config_file       = false
  host                   = module.gke.primary_cluster_endpoint
  token                  = module.gke.primary_cluster_token
  cluster_ca_certificate = module.gke.primary_cluster_ca_certificate
  client_key             = ""
  client_certificate     = ""
  depends_on_nginx_plus  = [module.gke.primary_endpoint, module.gke.node_pool, module.gke.endpoint]
}

module "api-deployment" {
  source  = "./modules/apis"
  tls_crt = file("default.crt")
  tls_key = file("default.key")
  image   = "ingress/${var.ingress_controller_image_name}:${var.ingress_conroller_version}"

  load_config_file       = false
  host                   = module.gke.primary_cluster_endpoint
  token                  = module.gke.primary_cluster_token
  cluster_ca_certificate = module.gke.primary_cluster_ca_certificate
  client_key             = ""
  client_certificate     = ""
  weather-api-image      = var.weather-api-image
  echo-api-image         = var.echo-api-image
  swapi-image            = var.swapi-image
  depends_on_nginx_plus  = [module.nginx-plus-ingress-deployment.lb_ip, module.gke.primary_endpoint, module.gke.node_pool, module.gke.endpoint]

}

locals {
  external_loadbalancer = module.nginx-plus-ingress-deployment.lb_ip
  grafana_dashboard_url = module.prometheus.lb_ip
}

module "nginx-plus-ingress-deployment" {
  source = "./modules/nginx-plus"

  tls_crt                   = file("default.crt")
  tls_key                   = file("default.key")
  name_of_ingress_container = var.name_of_ingress_container
  ingress_conroller_version = var.ingress_conroller_version
  image                     = "${var.gke_container_registry_region}/${var.project_id}/${var.ingress_controller_image_name}:${var.ingress_conroller_version}"
  load_config_file          = false
  host                      = module.gke.primary_cluster_endpoint
  token                     = module.gke.primary_cluster_token
  cluster_ca_certificate    = module.gke.primary_cluster_ca_certificate
  client_key                = ""
  client_certificate        = ""
  depends_on_kube           = [module.gke.primary_endpoint, module.gke.node_pool, module.gke.endpoint]
}

module "gke" {
  depends_on_kic     = [module.kic.id, random_pet.myprefix]
  source             = "./modules/gke"
  project_id         = var.project_id
  region             = var.region
  kubernetes_version = var.gke_kubernetes_version
  machine_type       = var.machine_type
  gke_username       = var.gke_username
  gke_password       = var.gke_password
  gke_num_nodes      = var.gke_num_nodes
  network            = "${random_pet.myprefix.id}-${var.network}"
  subnetwork         = "${random_pet.myprefix.id}-${var.subnetwork}"
  tag_1_node_pool    = var.tag_1_node_pool
  tag_2_node_pool    = var.tag_2_node_pool
  unique_user_id     = var.unique_user_id
  environment        = var.environment
  subnetwork_cidr    = var.subnetwork_cidr
  gke_cluster_name   = "${random_pet.myprefix.id}-${var.gke_cluster_name}"
  initial_node_count = var.initial_node_count

  ingress_conroller_version     = var.ingress_conroller_version
  ingress_controller_prefix     = "${var.gke_container_registry_region}/${var.project_id}"
  ingress_controller_image_name = var.ingress_controller_image_name

}

module "kic" {
  source                        = "./modules/kic"
  ingress_conroller_version     = var.ingress_conroller_version
  ingress_controller_prefix     = "${var.gke_container_registry_region}/${var.project_id}"
  ingress_controller_image_name = var.ingress_controller_image_name
}

resource "random_pet" "myprefix" {
  length = 1
  prefix = var.prefix
}
