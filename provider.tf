terraform {
  required_providers {
    google = {
      source                = "hashicorp/google"
      version               = ">= 4.0.0"
      configuration_aliases = [google.cloudrun, google.project]
    }
  }
}