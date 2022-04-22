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
        image = REGISTRY_URL
        tag   = "latest"
        // local = true
        // encoded_auth = filebase64("${path.pwd}/auth.json")
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path   = "/healthz"
      image_secret = "gitlab"
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
        host    = GRPS_URL
        tls {
          hosts       = [GRPS_URL]
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
