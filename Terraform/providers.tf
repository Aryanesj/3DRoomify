# ---| Providers |------------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    github = {
      source = "integrations/github"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.4.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "github" {
  token = var.github_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
