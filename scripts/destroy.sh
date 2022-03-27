echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm del etcd konnectivity kube-apiserver main -n $CLUSTER_NAME
kubectl delete secrets --all