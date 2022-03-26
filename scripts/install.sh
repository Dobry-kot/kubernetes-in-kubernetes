echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm upgrade main charts/main/  --install --namespace=cluster-2 --wait
helm upgrade konnectivity charts/konnectivity/
helm install kube-apiserver charts/kube-apiserver/