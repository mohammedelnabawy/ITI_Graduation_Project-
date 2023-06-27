resource "kubernetes_service_account" "jenkins-identity" {
  metadata {
    name = "jenkins-identity"
  }
}

resource "kubernetes_cluster_role" "jenkins-Cluster-Role" {
  metadata {
    name = "jenkins-Cluster-Role"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins-Cluster-RoleBinding" {
  metadata {
    name = "jenkins-Cluster-RoleBinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins-Cluster-Role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins-identity.metadata.0.name
    namespace = kubernetes_namespace.tools.metadata.0.name
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins-deployment"
    namespace = "${kubernetes_namespace.tools.metadata.0.name}"  
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.jenkins-identity.metadata.0.name
        container {
          image = "elnabawy/jenkins-docker-kubectl"
          name  = "jenkins-container"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
