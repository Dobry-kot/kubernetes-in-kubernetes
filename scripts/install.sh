echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm install main charts/main/                      --namespace=$CLUSTER_NAME --wait
helm install etcd charts/etcd/                      --namespace=$CLUSTER_NAME 
helm install konnectivity charts/konnectivity/      --namespace=$CLUSTER_NAME
helm install kube-apiserver charts/kube-apiserver/  --namespace=$CLUSTER_NAME