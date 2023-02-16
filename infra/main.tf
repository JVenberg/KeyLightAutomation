
### Data and Locals ##
data "google_billing_account" "account" {
  display_name = "default"
  open         = true
}

data "google_container_registry_image" "keylightautomation" {
  name = "keylightautomation"
  tag  = "latest"
}

data "google_compute_default_service_account" "default" {
}

locals {
  project_id = "keylightautomation-378015"
  region     = "us-west1"
  zone       = "us-west1-a"
}

### Provider ###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

### Resources ###
resource "google_project" "project" {
  name            = "KeyLightAutomation"
  project_id      = local.project_id
  billing_account = data.google_billing_account.account.id
}

resource "google_cloud_run_v2_job" "off" {
  name         = "keylight-off"
  location     = local.region
  launch_stage = "BETA"

  template {
    template {
      containers {
        image = data.google_container_registry_image.keylightautomation.image_url
        env {
          name  = "KLIGHT_IP"
          value = "<PLACEHOLDER>"
        }
        env {
          name  = "KLIGHT_PORT"
          value = "<PLACEHOLDER>"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      template[0].template[0].containers[0].env[1].value,
      template[0].template[0].containers[0].env[0].value
    ]
  }
}

resource "google_cloud_run_v2_job" "on" {
  name         = "keylight-on"
  location     = local.region
  launch_stage = "BETA"

  template {
    template {
      containers {
        image = data.google_container_registry_image.keylightautomation.image_url
        env {
          name  = "KLIGHT_IP"
          value = "<PLACEHOLDER>"
        }
        env {
          name  = "KLIGHT_PORT"
          value = "<PLACEHOLDER>"
        }

        command = [
          "python",
          "controller.py",
        ]
        args = [
          "--on"
        ]
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      template[0].template[0].containers[0].env[1].value,
      template[0].template[0].containers[0].env[0].value
    ]
  }
}

resource "google_cloud_scheduler_job" "cron_off" {
  name      = "keylightautomation-cron-off"
  schedule  = "0 18 * * *"
  time_zone = "America/Los_Angeles"

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.off.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${local.project_id}/jobs/${google_cloud_run_v2_job.off.name}:run"
    oauth_token {
      service_account_email = data.google_compute_default_service_account.default.email
    }
  }

  retry_config {
    min_backoff_duration = "5s"
    max_retry_duration   = "0s"
    max_doublings        = 5
    retry_count          = 5
  }
}


resource "google_cloud_scheduler_job" "cron_on" {
  name      = "keylightautomation-cron-on"
  schedule  = "0 8 * * *"
  time_zone = "America/Los_Angeles"

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.on.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${local.project_id}/jobs/${google_cloud_run_v2_job.on.name}:run"
    oauth_token {
      service_account_email = data.google_compute_default_service_account.default.email
    }
  }

  retry_config {
    min_backoff_duration = "5s"
    max_retry_duration   = "0s"
    max_doublings        = 5
    retry_count          = 5
  }
}

