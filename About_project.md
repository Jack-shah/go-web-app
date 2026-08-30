
# LOCALBUILD AND TEST
    * Now we got the code and  we know we need to build the code before running
    * So for build we will be needing golang as it is a golang project install it.
    * To build the code run go build -o main  in the root folder of project
    * For the particular project the code has been cloned from :https://github.com/iam-veeramalla/go-web-app.git
    * Doing so will create a folder name main as we defined while building. this  is the  output binary 
    * Now to test this binary we can run it locally  from root folder  # ./main
    * it will run the applictaion  we can access the application  on browser http://localhost:8080/cource  as defined in ReadME.md file

# CONTAINERIZE THE APPLICATION AND TEST
    * now once we know application is running locally we can write dockerfile to create container image of the application.....
    * Build the Docker image run # docker build -t <dockerhub_username>/yourappname:tag
    * Once image is ready we need to test it as well  for this we will run app with port forwarding
    * docker run -p:8080:8080 -it awajid3/go-web-app:1.00
    * if container runs check on browser  : http://localhost:8080/courses it should be live
 
# PUSH THIS IMAGE  TO YOUR REGISTERY SERVER  OR DOCKERHUB
    * docker login -u <you username on dockerhub>
    * then paste the PAT

# NOW CREATE THE DEPLOYMENT FILES FOR K8s
* like deployment.yaml , service.yaml, ingress.yaml

# THEN WE START MAKING KUBERNETES CLUSTER
    * I create minikube cluster on my laptop and install the kubectl  to interact with the cluster
    * Applied those configuration yaml file to creat deployment, service and ingress
    * Once Pod is running ,i have tp check if accessible from outside cluster for this
    * to locally test i used port frowarding.....
    * Another way i have created ingress yaml file to set the incoming traffice rules
    * install ingress nginx controller on minikube
    * Now ingress controller will act as single gateway to the application in POD
    * So to access this app now i will port forward the ingress controller service POD 

# https://v1-33.docs.kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
    * ingress controller is golang program written by Load Balancer companies like nginx, HA proxy,aws ,traeffic
    * ingress controller watch the ingress yaml file(ingress resource) and create the load balancer as per ingress resource yaml file
    * in our case(minikube cluster) no loadbalancer will be created instead a nginx-controller will run on POD.........again the POD is running in the cluster...
    * SO whenever you access that specific controller Pod—whether you reach it directly via its internal IP, an exposed NodePort, a minikube tunnel, or a kubectl port-forward pipeline—the Pod automatically reads your incoming request header, looks up your Ingress routing rules, and safely hands the traffic off to your application Pod.
    * portforwarding:  
    * #kubectl port-forward -n ingress-nginx deployment/ingress-nginx-controller 8080:80 --address=0.0.0.0
    * so we were able to access the application from windows browser:

# Moving Ahead Packaging our project to helmchart
    * Now we will convert our project into helmchart use k8s docs on gdrive
    * install helm package # sudo snap install helm --classic
    * At root of project directory create helm chart folder # helm create go-web-app
    * it will create values.yaml file, template folder, and chart.yaml file
    * to template folder copied the k8s yaml file(deplyment.yaml, service.yaml, ingress.yaml)
    * in values.yaml file defined the variables value like image tag for deployemnt yaml file.
    * Remove all existing resource from cluster
    * create resources (pod, service, ingress) using helm # helm install dev .(. is the path to chart.yaml file)
    * use this command to check what manifest helm is using to create resources(pod,ingress, service)helm template dev helm/springboot_app_chart/

# Continuous Integration

    * Automating all task done before 
    * CI part(build, test,static code test, and will docker image and will push it to dockerhub)using github actions
    * Github action is similar to jenkins job build in jenkins we used jenkinsfile here we will be using .github/workflows/cicd.yaml (workflow file) to build the job 
    * .github/workflows this specific path at root of your project is required buy github to trigger the job build
    * You can learn more on github action on my documentation  file names git on google drive....

# Next Part is Continuous DEPLOYMENT using ARGOCD
* Creates an isolated logical space (namespace) inside your cluster specifically for Argo CD resources.
* kubectl create namespace argocd
* Installs Argo CD using server-side execution. The '--server-side' flag tells the cluster API to handle 
* the massive YAML file, and '--force-conflicts' ensures any existing fields are cleanly overwritten.
* kubectl apply -n argocd --server-side --force-conflicts -f https://githubusercontent.com
* Lists every workload (Pods, Services, Deployments, ReplicaSets) inside the argocd namespace to verify they are running.
* kubectl get all --namespace argocd
* Creates a network tunnel from your cluster to your host machine using custom port 8083. 
* '--address 0.0.0.0' allows your Windows browser to access the UI via https://localhost:8083.
* kubectl port-forward svc/argocd-server -n argocd 8083:443 --address 0.0.0.0
* we can now access the argo cd app running as pod in our cluster using localhost:8083
* It will ask for username <admin> and password(next instruction)
* Lists all secure data objects (Secrets) in the namespace so you can identify the one holding the initial admin password.
* kubectl get secrets -n argocd
* Opens the secret configuration file in an interactive text editor so you can manually find and copy the encrypted password string.
* kubectl edit secret argocd-initial-admin-secret -n argocd
* Takes your copied, encrypted base64 password string and translates it back into readable, plain text so you can log into the UI.
* echo R0gtNU9MTEl5Y3B5R21Hbg== | base64 --decode
* it will give you plain text password which you can paste into argocd app in browser
* Now once we logged in the argocd server  we can configure our project there
* repository will be git hub repo and argocd will watch is go-web-app/values.yaml if the values is changed in this file argocd will trigger the job and will start rolling update...

# ARGOCD project create setting
* Application Name: go-web-app
* Project Name: defaultSync Policy: Set to Automatic and check SelfHeal. (SelfHeal ensures that if someone manually messes with your MiniKube cluster using kubectl, Argo CD will instantly overwrite it to match Git
* Repository URL: https://github.comRevision: HEAD (or main)
* Path: go-web-app (This is the folder containing your Helm chart).
* Destination Cluster URL: https://default.svc (This always points to the local cluster Argo CD is currently running inside).
* Destination Namespace: default