variable "project_prefix" {
  type        = string
  description = "Prefix for the project name"
  default     = "fantastic-octo-winner"
}

variable "project_billingaccount" {
  type        = string
  description = "Project Billing Account"
}

variable "use_cloudrun" {
  type        = bool
  description = "Binary switch to run the app(s) on Cloud Run vs GKE"
  default     = false
}

variable "gke_autopilot" {
  type        = bool
  description = "Binary switch to enable/disable autopilot GKE cluster"
  default     = true
}