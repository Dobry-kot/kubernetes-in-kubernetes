echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm del kube-scheduler etcd konnectivity kube-apiserver main kube-controller-manager -n $CLUSTER_NAME
kubectl delete secrets --all
