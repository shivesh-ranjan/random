# Steps:
### Installing Cloud Controller Manager:
1. Cloud.conf file:
   ```
   [Global]
   auth-url=<auth-url>
   username=<username>
   password=<password>
   region=<region>
   tenant-id=<project-id>
   tenant-domain-id=default
   domain-id=default
 
   [LoadBalancer]
   floating-subnet-id=<External-Subnet-ID>
   subnet-id=<Private-Network-ID>
   ```
2. Creating a secret:
   ```
   kubectl create secret -n kube-system generic cloud-config --from-file=cloud.conf
   ```
3. Installing CCM:
   ```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml
   ```
4. Wait for pods to be ready:
   ```
   kubectl get pods -n kube-system -w
   ```
5. Verify:
   ```
   kubectl run hostname-server --image=lingxiankong/alpine-test --port=8080
   kubectl expose pod hostname-server --type=LoadBalancer --target-port=8080 --port=80 --name hostname-server
   kubectl get svc hostname-server -w
   ```
### Installing Cinder CSI Plugin
1. Clone Repo
   ```
   git clone https://github.com/kubernetes/cloud-provider-openstack && cd cloud-provider-openstack
   git checkout tags/v1.30.0
   ```
2. Check for cloud-config secret:
   ```
   kubectl get secret -n kube-system cloud-config
   ```
3. Install CSI cinder controller plugin:
   ```
   rm manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
   kubectl -f manifests/cinder-csi-plugin/ apply
   kubectl get pods -n kube-system | grep csi-cinder
   ```
4. View Drivers:
   ```
   kubectl get csidrivers.storage.k8s.io
   ```

### Others:
1. Ingress-nginx:
   ```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
   ```
2. Cert Manager:
   ```
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
   ```
3. Installing Helm:
   ```
   curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
   sudo apt-get install apt-transport-https --yes
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
   sudo apt-get update
   sudo apt-get install helm
   ```
4. Installing Grafana:
   ```
   helm repo add grafana https://grafana.github.io/helm-charts
   helm repo update
   kubectl create namespace monitoring
   helm install my-grafana grafana/grafana --namespace monitoring
   ```


Credits:
* https://openmetal.io/docs/manuals/kubernetes-guides/installing-the-kubernetes-openstack-cloud-controller-manager
* https://openmetal.io/docs/manuals/kubernetes-guides/configuring-openstack-cinder-with-kubernetes

Optional Resources:
* https://kubernetes.github.io/ingress-nginx/deploy/
* https://cert-manager.io/docs/installation/
* https://letsencrypt.org/getting-started/
* https://kubernetes.github.io/ingress-nginx/user-guide/tls/
