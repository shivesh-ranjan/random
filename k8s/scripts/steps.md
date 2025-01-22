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

Credits:
* https://openmetal.io/docs/manuals/kubernetes-guides/installing-the-kubernetes-openstack-cloud-controller-manager
* https://openmetal.io/docs/manuals/kubernetes-guides/configuring-openstack-cinder-with-kubernetes

Optional Resources:
* https://kubernetes.github.io/ingress-nginx/deploy/
* https://cert-manager.io/docs/installation/
* https://letsencrypt.org/getting-started/
* https://kubernetes.github.io/ingress-nginx/user-guide/tls/
