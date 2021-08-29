module "network" {
  source = "./modules/network/default"
  // base network parameters
  network_name    = "kube"
  subnetwork_name = "kube-subnet"
  region          = "europe-west3"
  // subnetwork primary and secondary CIDRS for IP aliasing
  subnetwork_range    = "10.40.0.0/16"
  subnetwork_pods     = "10.41.0.0/16"
  subnetwork_services = "10.42.0.0/16"
}

module "cluster" {
  source                           = "./modules/gke/control-plane"
  region                           = "europe-west3"
  name                             = "k8s-cainelli-dev"
  network_name                     = "kube"
  nodes_subnetwork_name            = module.network.subnetwork
  kubernetes_version               = "1.20.8-gke.2100"
  pods_secondary_ip_range_name     = module.network.gke_pods_1
  services_secondary_ip_range_name = module.network.gke_services_1
}

module "node_pool" {
  source                     = "./modules/gke/node-pool"
  name                       = "k8s-cainelli-node-pool"
  region                     = module.cluster.region
  gke_cluster_name           = module.cluster.name
  machine_type               = "e2-standard-2"
  min_node_count             = "0"
  max_node_count             = "1"
  kubernetes_version         = module.cluster.kubernetes_version
  node_service_account_email = module.cluster.node_service_account.email
}
