echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm upgrade main charts/main/. -n $CLUSTER_NAME --install
helm upgrade etcd charts/etcd/. -n $CLUSTER_NAME --install

helm upgrade kube-apiserver-pre-proc charts/kube-apiserver-pre-proc/. -n $CLUSTER_NAME --install
helm upgrade konnectivity-pre-proc charts/konnectivity-pre-proc/. -n $CLUSTER_NAME --install

sleep 15

LOADBALANCER_IP=$(kubectl get svc kubernetes-apiserver -n $CLUSTER_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
KONNECTIVITY_IP=$(kubectl get svc konnectivity-server -n $CLUSTER_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $LOADBALANCER_IP
echo $KONNECTIVITY_IP

# 
helm upgrade konnectivity charts/konnectivity/. -n $CLUSTER_NAME --install
helm upgrade kube-apiserver charts/kube-apiserver/. -n $CLUSTER_NAME --install

helm upgrade kube-controller-manager charts/kube-controller-manager/. -n $CLUSTER_NAME --install
helm upgrade kube-scheduler charts/kube-scheduler/. -n $CLUSTER_NAME --install

# helm del konnectivity-pre-proc kube-apiserver-pre-proc
