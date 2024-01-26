terraform {
  required_version = ">=1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
  }

}

locals {
  name = var.instance == "default" ? var.name : "${var.name}-${var.instance}"
  selector_labels = {
    "app.kubernetes.io/name"     = var.name
    "app.kubernetes.io/instance" = var.instance
  }
  common_labels = {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/instance"   = var.instance
    "app.kubernetes.io/version"    = var.image_tag
    "app.kubernetes.io/managed-by" = "terraform"
  }
  labels = merge(local.selector_labels, local.common_labels, var.extra_labels)
}
