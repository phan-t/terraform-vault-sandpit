slot {
  server = "${vault_address}:5696"
  tls_cert_path = "${path_tls_cert}"
  ca_path = "${path_ca_cert}"
  scope = "${kmip_scope}"
}