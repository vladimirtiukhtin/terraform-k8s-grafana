resource "kubernetes_deployment_v1" "grafana" {

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.selector_labels
    }

    template {

      metadata {
        labels = local.labels
      }

      spec {

        priority_class_name = var.priority_class

        security_context {
          run_as_user  = var.user_id
          run_as_group = var.group_id
          fs_group     = var.group_id
        }

        affinity {
          dynamic "node_affinity" {
            for_each = var.node_affinity != null ? { node_affinity = var.node_affinity } : {}
            content {
              dynamic "required_during_scheduling_ignored_during_execution" {
                for_each = node_affinity.value["kind"] == "required" ? { node_selector_term = {} } : {}
                content {
                  node_selector_term {
                    match_expressions {
                      key      = node_affinity.value["label"]
                      operator = "In"
                      values   = [node_affinity.value["value"]]
                    }
                  }
                }
              }
              dynamic "preferred_during_scheduling_ignored_during_execution" {
                for_each = node_affinity.value["kind"] == "preferred" ? { node_selector_term = {} } : {}
                content {
                  weight = 1
                  preference {
                    match_expressions {
                      key      = node_affinity.value["label"]
                      operator = "In"
                      values   = [node_affinity.value["value"]]
                    }
                  }
                }
              }
            }
          }
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values   = [var.name]
                }
                match_expressions {
                  key      = "app.kubernetes.io/instance"
                  operator = "In"
                  values   = [var.instance]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          name              = var.name
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = var.image_tag == "latest" ? "Always" : "IfNotPresent"

          security_context {
            run_as_user  = var.user_id
            run_as_group = var.group_id
          }

          dynamic "env" {
            for_each = merge({
              GF_SERVER_HTTP_PORT = var.port
              GF_PATHS_DATA       = var.storage_path
            }, var.extra_env)
            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = var.port
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          volume_mount {
            name       = "data"
            mount_path = var.storage_path
          }

          readiness_probe {
            period_seconds        = 10
            initial_delay_seconds = 60
            success_threshold     = 1
            failure_threshold     = 3
            timeout_seconds       = 3

            http_get {
              scheme = "HTTP"
              path   = "/api/health"
              port   = "http"
            }
          }
        }

        volume {
          name = "data"

          dynamic "persistent_volume_claim" {
            for_each = var.storage_class != null ? { data = {} } : {}
            content {
              claim_name = kubernetes_persistent_volume_claim.grafana.metadata.0.name
            }
          }

          dynamic "empty_dir" {
            for_each = var.storage_class == null ? { data = {} } : {}
            content {}
          }

        }

      }

    }

  }
  wait_for_rollout = var.wait_for_rollout
}

resource "kubernetes_persistent_volume_claim" "grafana" { // ToDo: consider switching to a shared database
  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
  wait_until_bound = false
}
