output "cme-command" {
  sensitive = true
  value = "autoprov_cfg -f init AWS -ak ${aws_iam_access_key.cme-user-key.id} -sk ${aws_iam_access_key.cme-user-key.secret} -mn ${var.cme_management_server} -tn ${var.cme_configuration_template} -cn gwlb-controller -po ${var.gateways_policy} -otp ${var.gateway_SICKey} -r ${var.region} -ver ${split("-", var.gateway_version)[0]}"
}

