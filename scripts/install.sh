echo "Enter cluster name: "
CLUSTER_NAME=cluster-2


# helm upgrade main charts/main/ --install --wait --timeout=60s
# helm upgrade etcd charts/etcd/ --install \
# --set applications.etcd.Deployment.containers.etcd.image="gcr.io/etcd-development/etcd:v3.5.2"

# helm upgrade kube-apiserver charts/kube-apiserver/ --install \
# --set applications.kubeApiserver.Deployment.containers.kubeApiserver.image="k8s.gcr.io/kube-apiserver:v${CLUSTER_VERSION}"
# --set applications.kubeApiserver.extraParams.serviceCIDR="30.64.0.0/16" \
# --set applications.kubeApiserver.extraParams.oidc.enable="false"

# helm upgrade kube-scheduler charts/kube-scheduler/ --install \
# --set applications.kubeScheduler.Deployment.containers.kubeScheduler.image="k8s.gcr.io/kube-scheduler:v${CLUSTER_VERSION}"

# helm upgrade kube-controller-manager charts/kube-controller-manager/ --install \
# --set applications.kubeControllerManager.Deployment.containers.kubeControllerManager.image="k8s.gcr.io/kube-controller-manager:v${CLUSTER_VERSION}"
export CLUSTER_VERSION="1.23.5"
helm upgrade main charts/main --install --wait --timeout=60s
helm upgrade terra-kube . --install  \
--set kube-apiserver.applications.kubeApiserver.extraParams.serviceCIDR="30.64.0.0/16" \
--set kube-apiserver.applications.kubeApiserver.extraParams.oidc.enable="false" \
--set kube-apiserver.applications.kubeApiserver.Deployment.containers.kubeApiserver.image="k8s.gcr.io/kube-apiserver:v${CLUSTER_VERSION}" \
--set kube-scheduler.applications.kubeScheduler.Deployment.containers.kubeScheduler.image="k8s.gcr.io/kube-scheduler:v${CLUSTER_VERSION}" \
--set kube-controller-manager.applications.kubeControllerManager.Deployment.containers.kubeControllerManager.image="k8s.gcr.io/kube-controller-manager:v${CLUSTER_VERSION}" \
--set etcd.applications.etcd.Deployment.containers.etcd.image="quay.io/coreos/etcd:v3.5.2"


helm upgrade cilium cilium/cilium --version 1.11.3 \
    --install \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=51.250.13.121 \
    --set k8sServicePort=6443

helm install victoria-metrics vm/victoria-metrics-operator --namespace=vm-metrics


export folders=(certmanager victoriaMetrics prometheus-adapter monitoring-client metric-server kube-state-metrics konnectivity-client)
for folder in ${folders[*]}
do
for i in $(ls charts/addons/charts/$folder/client | grep yaml); do ka -f charts/addons/charts/$folder/client/$i ; done;
done

export folder=victoriaMetrics
for i in $(ls charts/addons/charts/$folder/client | grep yaml); do ka -f charts/addons/charts/$folder/client/$i ; done;
