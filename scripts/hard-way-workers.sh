export CLUSTER_VERSION="1.23.5"
export CONTAINERD="1.6.2"
export CNI_PLUGIN="1.1.1"
export RUNC="1.0.0-rc93"
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.23.0/crictl-v1.23.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v${RUNC}/runc.amd64 \
  https://github.com/containerd/containerd/releases/download/v${CONTAINERD}/containerd-${CONTAINERD}-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v${CLUSTER_VERSION}/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v${CLUSTER_VERSION}/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v${CLUSTER_VERSION}/bin/linux/amd64/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kubernetes \
  /var/run/kubernetes \
  containerd

tar -xvf crictl-v*-linux-amd64.tar.gz
tar -xvf containerd-*-linux-amd64.tar.gz -C containerd
sudo mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
sudo mv containerd/bin/* /bin/

cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF

sudo mkdir -p /etc/containerd/

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "30.64.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/tls.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/tls.key"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kubelet/kubeconfig"
mode: "ipvs"
clusterCIDR: "30.64.0.0/16"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

export instance="fhmb9ncss8s114jq0n7k"

cat <<EOF | sudo tee /tmp/fhmb9ncss8s114jq0n7k
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: "pki-system-node-fhmb9ncss8s114jq0n7k"
spec:
  commonName: "system:node:fhmb9ncss8s114jq0n7k"
  secretName: "pki-system-node-fhmb9ncss8s114jq0n7k"
  duration: 8760h # 365d
  renewBefore: 4380h # 178d
  subject:
    organizations:
    - "system:nodes"
  usages:
    - "signing"
    - "key encipherment"
    - "client auth"
    - "server auth"
  dnsNames:
    - fhmb9ncss8s114jq0n7k
  ipAddresses:
    - 10.128.0.23
  issuerRef:
    name: "issuer"
    kind: Issuer
EOF

cat <<EOF | sudo tee /var/lib/kubelet/kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
    server: https://51.250.105.203:6443
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
preferences: {}
users:
- name: default-auth
  user:
    client-certificate: /var/lib/kubelet/tls.crt
    client-key: /var/lib/kubelet/tls.key
EOF

