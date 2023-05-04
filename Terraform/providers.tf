# ---| Providers |------------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "< 5.0.0"
    }
    github = {
      source = "integrations/github"
      version = "< 5.30.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "< 5.0.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
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
