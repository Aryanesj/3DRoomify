# --------------------------------------------------------------
# Use Terraform with GCP
# Made by Artem Burmak 
# 2023
# --------------------------------------------------------------
provider "google" {
  credentials = file(var.credentials_file_path)
  project     = "avid-factor-384910"
  region      = "europe-west3"
  zone        = "europe-west3-a"
}
