# Multi-docker deployment with Kubernetes

## Creating SECRETS to securely store sensitive information within the k8s cluster

### Types of secrets

1. "generic" - used in most cases for general encrypted data
2. "docker-registry" - used for settings up some type of auth with a docker registry
3. "tls" - used specifically for HTTPS setup with TLS keys/tokens

### Commands/Args Template

```k8s
kubectl <imperative command> <object type> <secret type> <secret name> --from-literal <key=value>
```

### Usage Example

```k8s
kubectl create secret generic pgpassword --from-literal PGPASSWORD=password123
```

## Creating Kubenetes dashboard for use with Docker Desktop Version:

Docker Desktop's Kubernetes Dashboard
This note is for people using Docker Desktop's built-in Kubernetes. If you are using Minikube, the setup here does not apply to you and can be skipped.

If you are using Docker Desktop's built-in Kubernetes, setting up the admin dashboard is going to take a little more work.

1. Grab the kubectl script we need to apply from the GitHub repository: https://github.com/kubernetes/dashboard

2. We will need to download the config file locally so we can edit it (make sure you are copying the most current version from the repo).

   If on Mac or using GitBash on Windows enter the following at the root of your project directory:

   ```
   curl -O https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
   ```

   If using PowerShell:

   ```
   Invoke-RestMethod -Uri https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml -Outfile kubernetes-dashboard.yaml
   ```

3. Open up the downloaded file in your code editor and find line 116. Add the following two lines underneath --auto-generate-certificates:

   args:

   \- --auto-generate-certificates<br>
   \- --enable-skip-login<br>
   \- --disable-settings-authorizer

4. Run the following command inside the directory where you downloaded the dashboard yaml file a few steps ago:

   ```k8s
   kubectl apply -f kubernetes-dashboard.yaml
   ```

5. Start the server by running the following command:

   ```
   kubectl proxy
   ```

6. You can now access the dashboard by visiting:

   http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

7. You will be presented with a login screen

8. Click the "SKIP" link next to the SIGN IN button.

9. You should now be redirected to the Kubernetes Dashboard:

Important! The only reason we are bypassing RBAC Authorization to access the Kubernetes Dashboard is because we are running our cluster locally. You would never do this on a public facing server like Digital Ocean and would need to refer to the official docs to get the dashboard setup:
https://github.com/kubernetes/dashboard/wiki/Access-control

## Configuring G-Cloud Kubernetes Cluster for command shell access with kubectl

Every time a new kubernetes cluster is created in G-Cloud for a new project, to access and use the "kubectl" command to create secrets in the cloud or other configuration data, the following steps will need to be followed:

1.  Open the Cloud Shell in G-Cloud Dashboard (icon on top bar)

2.  Type the following commands:

    ```
    gcloud config set project [GCLOUD PROJECT NAME ID]
    gcloud config set compute/zone [GCLOUD COMPUTE ZONE]
    gcloud container clusters get-credentials [CLUSTER NAME]
    ```

    Usage Example:

    ```
    gcloud config set project multi-k8s-274002
    gcloud config set compute/zone us-central1-c
    gcloud container clusters get-credentials multi-cluster
    ```

    NOTE: These commands only need to be run ONCE per active kubernetes cluster in the G-Cloud.

## Add HELM V3 to G-Cloud Cluster and Install Ingress-Nginx

1.  Open the Cloud Shell in G-Cloud Dashboard (icon on top bar)

2.  Run these commands to install and configure HEML V3:

    ```
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
    ```

3.  Run these commands to install and configure Ingress-Nginx with HELM V3:

    ```
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    helm install my-nginx stable/nginx-ingress --set rbac.create=true
    ```

    Essentially this allows the creation of ingress/routing configurations and rules to the current kubernetes cluster via HELM V3 while still keeping kubernetes security standards intact.
