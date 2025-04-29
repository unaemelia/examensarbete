package k8sdisallowimagepullpolicyalways

violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  container.imagePullPolicy == "Always"
  msg := "imagePullPolicy: Always is not allowed"
}