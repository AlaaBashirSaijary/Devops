terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

# يستخدم نفس إعدادات kubectl الحالية (kind أو minikube أو Docker Desktop)
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "hello-devops"
  }
}
