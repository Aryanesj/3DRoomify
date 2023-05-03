# --- Variables -----------------------------------------------------------
variable "credentials_file_path" {
  description = "Path to the GCP credentials JSON file"
}

variable "project" {
  description = "GCP Project ID"
  default     = "avid-factor-384910"
}

variable "region" {
  description = "GCP Region"
  default     = "europe-west3"
}

variable "zone" {
  description = "GCP Zone"
  default     = "europe-west3-a"
}

variable "github_token" {
  description = "GitHub Personal Access Token"
}

variable "github_owner" {
  description = "GitHub owner"
  default     = "Aryanesj"
}

variable "github_repository" {
  description = "GitHub repository"
  default     = "D-A-3D-Visualization"
}

variable "cloudflare_api_token" {
  description = "CloudFlare API Token"
}
