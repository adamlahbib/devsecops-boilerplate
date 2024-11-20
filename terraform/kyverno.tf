resource "helm_release" "kyverno" {
    name = "kyverno"
    repository = "https://kyverno.github.io/kyverno/"
    chart = "kyverno"
    namespace = "kyverno"
    create_namespace = true
    version = "3.3.3"

    depends_on = [aws_eks_node_group.eks_nodes]
}

resource "kubectl_manifest" "restrict_container_registry" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-contrainer-registries
spec:
  validationFailureAction: enforce
  background: true # Check existing resources
  rules:
    - name: restrict-contrainer-registries
      match:
        resources:
          kinds:
            - Pod
          namespaces:
            - dev
            - prod
      validate:
        message: "The container image must come from the approved ECR registry."
        pattern:
          spec:
            containers:
              - image: "*.dkr.ecr.eu-west-3.amazonaws.com/aqemia-adaml-repo:*"
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "disallow_latest_tag" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: enforce
  background: true # Check existing resources
  rules:
    - name: require-image-tag
      match:
        resources:
          kinds:
            - Pod
          namespaces:
            - dev
            - prod
      validate:
        message: "The container must image must have a tag other than latest"
        pattern:
          spec:
            containers:
              - image: "?*:*"
              - image: "!*:latest"
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "disallow_nodeport" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-nodeport-service
spec:
  validationFailureAction: enforce
  background: true # Check existing resources
  rules:
    - name: disallow-nodeport-service
      match:
        resources:
          kinds:
            - Service
          namespaces:
            - dev
            - prod
      validate:
        message: "The Service type 'NodePort' is not allowed."
        pattern:
          spec:
            type: "!NodePort"
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "allowed_replica_limit" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-max-replicas
spec:
  validationFailureAction: enforce
  rules:
    - name: enforce-max-replicas
      match:
        resources:
          kinds:
            - Deployment
            - StatefulSet
            - ReplicaSet
      namespaceSelector:
        matchNames:
          - prod
          - dev
      validate:
        message: "The number of replicas must not exceed 6."
        pattern:
          spec:
            replicas: "<=6"
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "disallow_default_namespace" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-default-namespace
spec:
  validationFailureAction: audit
  rules:
    - name: disallow-default-namespace
      match:
        resources:
          kinds:
            - Pod
            - Deployment
            - Service
            - StatefulSet
            - ReplicaSet
            - CronJob
            - Job
            - ConfigMap
            - Secret
            - PVC
      validate:
        message: "The 'default' namespace is not allowed for resource creation."
        pattern:
          metadata:
            namespace: "!default"
YAML
    depends_on = [helm_release.kyverno, kubernetes_service.nginx_ingress]
}

resource "kubectl_manifest" "disallow_privileged_containers" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
spec:
  validationFailureAction: enforce
  rules:
    - name: disallow-privileged-containers
      match:
        resources:
          kinds:
            - Pod
            - Deployment
            - StatefulSet
            - ReplicaSet
      namespaceSelector:
        matchNames:
          - prod
          - dev
      validate:
        message: "Privileged containers are not allowed in the 'prod' and 'dev' namespaces."
        pattern:
          spec:
            containers:
              - securityContext:
                  privileged: false 
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "require_pod_probes" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pod-probes
spec:
  validationFailureAction: enforce
  rules:
    - name: require-pod-probes
      match:
        resources:
          kinds:
            - Pod
            - Deployment
            - StatefulSet
            - ReplicaSet
      namespaceSelector:
        matchNames:
          - prod
          - dev
      validate:
        message: "Liveness and readiness probes must be set for containers."
        pattern:
          spec:
            containers:
              - readinessProbe: "?*"
YAML
    depends_on = [helm_release.kyverno]
}

resource "kubectl_manifest" "require_resource_limits" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resource-limits
spec:
  validationFailureAction: enforce
  rules:
    - name: require-resource-limits
      match:
        resources:
          kinds:
            - Pod
            - Deployment
            - StatefulSet
            - ReplicaSet
      namespaceSelector:
        matchNames:
          - prod
          - dev
      validate:
        message: "Resource limits must be set for CPU and memory in the 'prod' and 'dev' namespaces."
        pattern:
          spec:
            containers:
              - resources:
                  limits:
                    cpu: "<=2" 
                    memory: "<=1Gi"  
YAML
    depends_on = [helm_release.kyverno]
}
