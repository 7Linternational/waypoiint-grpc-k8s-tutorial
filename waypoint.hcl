variable "REGISTRY_URL" {
    default     = ""
    type        = string
    description = "URL for your container registry."
}

variable "GRPS_URL" {
    default     = ""
    type        = string
    description = "URL for your TLS enabled gRPC service endpoint."
}

project = "go-grpc"

app "go-grpc" {
  labels = {
    "service" = "go-grpc",
    "app"     = "go-grpc",
    "env"     = "dev"
  }

  build {
    use "pack" {}
    registry {
      use "docker" {
        image = var.REGISTRY_URL
        tag   = "latest"

        // Set to `true` if you don't want the image to be pushed to your container registry
        local = false

        // Required for private container registry
        // encoded_auth = filebase64("${path.pwd}/auth.json")
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path   = "/healthz"

      // Required for private container registry
      // image_secret = "secretname"

      pod {
        container {
          port {
            name = "http"
            port = 8080
          }
          port {
            name = "grpc"
            port = 50051
          }
        }
      }
    }
  }

  release {
    use "kubernetes" {
      // Sets up a load balancer to access released application
      load_balancer = false
      ports = [
        { "port" = "50051", "target_port" = "50051" }
      ]
      ingress "http" {
        default = false
        path    = "/"
        host    = var.GRPS_URL
        tls {
          hosts       = [var.GRPS_URL]
          secret_name = "grpc-tls"
        }
        annotations = {
          "kubernetes.io/ingress.class"                  = "nginx",
          "cert-manager.io/cluster-issuer"               = "letsencrypt-prod",
          "kubernetes.io/tls-acme"                       = "true",
          "nginx.ingress.kubernetes.io/ssl-redirect"     = "true",
          "nginx.ingress.kubernetes.io/backend-protocol" = "GRPC"
        }
      }
    }
  }
}
