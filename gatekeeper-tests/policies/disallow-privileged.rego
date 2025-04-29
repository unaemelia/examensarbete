package k8sdisallowprivileged

violation[{"msg": msg}] {
  input.review.kind.kind == "Deployment"
  container := input.review.object.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := "Privileged containers are not allowed"
}
