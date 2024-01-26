resource "kubernetes_service_v1" "grafana" {

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = var.service_annotations
    labels      = local.labels
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "http"
    }

    selector = local.selector_labels

  }

}
