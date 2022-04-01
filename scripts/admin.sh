TLS_KEY=$(kubectl get secrets pki-kube-apiserver-kubelet-client -o json | jq  .data | grep tls.key | awk  '{print $2}' | awk -F "," '{print $1}')
TLS_CRT=$(kubectl get secrets pki-kube-apiserver-kubelet-client -o json | jq  .data | grep tls.crt | awk  '{print $2}' | awk -F "," '{print $1}')
CA=$(kubectl get secrets pki-kube-apiserver-kubelet-client -o json | jq  .data | grep ca.crt | awk  '{print $2}' | awk -F "," '{print $1}')
API_IP=$(kubectl get svc kube-apiserver-proxy-svc | awk '{print $4}' | grep -iv external)

cat <<EOF > kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CA
    server: https://$API_IP:6443
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: yc-test
current-context: yc-test
kind: Config
preferences: {}
users:
- name: default-auth
  user:
    client-certificate-data: $TLS_CRT
    client-key-data: $TLS_KEY
EOF