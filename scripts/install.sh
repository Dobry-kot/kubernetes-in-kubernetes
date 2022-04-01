echo "Enter cluster name: "
CLUSTER_NAME=cluster-2

helm upgrade main charts/main/ --install --namespace=$CLUSTER_NAME --wait --timeout=60s
# helm upgrade etcd charts/etcd/                      --namespace=$CLUSTER_NAME && \
# helm upgrade konnectivity charts/konnectivity/      --namespace=$CLUSTER_NAME && \
# helm upgrade kube-apiserver charts/kube-apiserver/  --namespace=$CLUSTER_NAME && \
# helm upgrade kube-controller-manager charts/kube-controller-manager/  --namespace=$CLUSTER_NAME  && \
# helm upgrade kube-scheduler charts/kube-scheduler/  --namespace=$CLUSTER_NAME
helm upgrade terra-kube . --install  \
--set kube-apiserver.applications.kubeApiserver.extraParams.serviceCIDR="30.64.0.0/16" \
--set kube-apiserver.applications.kubeApiserver.extraParams.oidc.enable="false"
