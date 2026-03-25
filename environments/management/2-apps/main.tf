terraform {
  cloud {
    organization = "Mangrich"

    workspaces {
      name = "management-apps"
    }
  }

  required_version = ">= 1.9"
}
