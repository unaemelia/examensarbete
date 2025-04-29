package k8srequirelabels

required_labels := ["team", "owner"]

violation[{"msg": msg}] {
  input.review.kind.kind == "Pod"
  some i
  required_label := required_labels[i]
  not input.review.object.metadata.labels[required_label]
  msg := sprintf("Missing required label: %s", [required_label])
}