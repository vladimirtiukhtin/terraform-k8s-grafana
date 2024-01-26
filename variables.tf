variable "name" {
  description = "Common application name"
  type        = string
  default     = "grafana"
}

variable "instance" {
  description = "Common instance name"
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "Number of cluster nodes. Recommended value is the one which equals number of kubernetes nodes"
  type        = number
  default     = 1
}

variable "user_id" {
  description = "Unix UID to apply to persistent volume"
  type        = number
  default     = 472
}

variable "group_id" {
  description = "Unix GID to apply to persistent volume"
  type        = number
  default     = 0 // ToDo: may want to fix this
}

variable "image_name" {
  description = "Container image name including registry address. For images from Docker Hub short names can be used"
  type        = string
  default     = "grafana/grafana"
}

variable "image_tag" {
  description = "Container image tag (version)"
  type        = string
  default     = "10.1.1"
}

variable "service_annotations" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "port" {
  description = ""
  type        = number
  default     = 3000
}

variable "cpu_limit" {
  description = ""
  type        = string
  default     = "300m"
}

variable "memory_limit" {
  description = ""
  type        = string
  default     = "1024Mi"
}

variable "storage_class" {
  description = ""
  type        = string
  default     = null
}

variable "storage_path" {
  description = ""
  type        = string
  default     = "/var/lib/grafana"
}

variable "storage_size" {
  description = ""
  type        = string
  default     = "2Gi"
}

variable "priority_class" {
  description = ""
  type        = string
  default     = "system-cluster-critical"
}

variable "node_affinity" {
  description = ""
  type = object({
    kind  = string
    label = string
    value = string
  })
  default = null
}

variable "extra_env" {
  description = "Any extra environment variables to apply to MySQL StatefulSet"
  type        = map(string)
  default     = {}
}

variable "extra_labels" {
  description = "Any extra labels to apply to kubernetes resources"
  type        = map(string)
  default     = {}
}

variable "wait_for_rollout" {
  description = "Whether or not wait for readiness probe to succeed"
  type        = bool
  default     = true
}
