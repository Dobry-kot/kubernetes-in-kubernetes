crictl --runtime-endpoint unix:///var/run/crio/crio.sock ps -a
crictl --runtime-endpoint unix:///var/run/crio/crio.sock logs 

crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a
