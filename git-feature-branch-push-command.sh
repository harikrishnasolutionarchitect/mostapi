mkdir mostapi 
cd mostapi

git init

git checkout -b feature/mostapi-networktrac-0-1-0
git add .
git commit -m "feature/mostapi-networktrac-0-1-0"
git remote add origin https://github.com/harikrishnasolutionarchitect/mostapi.git
git branch -M feature/mostapi-networktrac-0-1-0
git push -u origin feature/mostapi-networktrac-0-1-0

 mkdir .github
 cd .github
 mkdir workflows

 cp -pr mostapi-deployment.yml .github/workflows/
 git add .
 git commit -m "mostapi deloyment yml file"

 git push -u origin feature/mostapi-networktrac-0-1-0



=============================== K8s Pod to Pod communication ====================

Pod will shutdown frequently , so we will go for service

servicename --> grouping of pod / list of pods

api   = [ api-pod01, api-pod02 , api-pod03 , api-pod04 , api-pod05 ]  ==> api-svc
app   = [ app-pod01, app-pod02 , app-pod03 , app-pod04 , app-pod05 ]  ==> app-svc
db    = [ db-pod01 , db-pod02  , db-pod03  , db-pod04  , db-pod05  ]  ==> db-svc



api-ns = [
   mostapi-pod01, mostapi-pod02 , mostapi-pod03 , mostapi-pod04 , mostapi-pod05,
   api=mostapi  , api=mostapi  , api=mostapi  , api=mostapi  , api=mostapi  , 

   mostapi-svc01  -- cluster-IP ==> 10.3.0.0:80
   api=mostapisvc  , 
]

app-ns = [ 
    busybox-pod01, busybox-pod02, busybox-pod03, busybox-pod04, busybox-pod01,
    app=busybox  ,app=busybox  , app=busybox  ,app=busybox  ,app=busybox  ,

    nginx-pod01, nginx-pod02, nginx-pod03, nginx-pod04, nginx-pod05,
    app=nginx , app=nginx ,  app=nginx ,   app=nginx ,  app=nginx ,


    lmsapp-pod01, lmsapp-pod02 , lmsapp-pod03 , lmsapp-pod04 , lmsapp-pod05, 
    app=lms   , app=lms   ,app=lms   ,app=lms   ,app=lms   ,

    postgredb-pod01, postgredb-pod02, postgredb-pod03, postgredb-pod04, postgredb-pod05 
    app=postgredb  ,app=postgredb  ,app=postgredb  ,app=postgredb  ,app=postgredb  ,
    
    web=nginx-svc01        -- cluster-IP ==> 10.4.1.0:80
    web=busybox-svc01      -- cluster-IP ==> 10.4.2.0:80
    api=mostapins-svc01,   -- cluster-IP ==> 10.4.0.0:80
    app=lmsapp-svc02       -- cluster-IP ==> 10.5.0.0:80
    db=db-svc             -- cluster-IP ==> 10.6.0.0:80 
    ]
nginx-controller-ns = [
    nginxcontroller-pod01, nginxcontroller-pod02, nginxcontroller-pod03, nginxcontroller-pod04, nginxcontroller-pod05,
    web=nginxcontroller
    
    nginxcontroller-svc01    -- cluster-IP ==> 10.7.0.0:80
]

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
   name: nginxcontroller-deny-all-ingress-traffic
   namespace:
     name: nginx-controller-ns
spec:
  policyTypes:
  - ingress:
  - egress:
  namespaceSelector: 
    matchLabels:
      kubernetes.io/metadata.name: kube-system
  podSelector: {}
  egress: []
  ingress: []

  engress:
    ports:
      port: 53
      protocol: TCP
      port: 8080
      protocol: TCP
  







monitoring-ns = [
    newrelic-pod01, newrelic-pod02, newrelic-pod03, newrelic-pod04, newrelic-pod05 
    promethesus-pod01, promethesus-pod02, promethesus-pod03, promethesus-pod04, promethesus-pod05,
    grafana-pod01, grafana-pod02, grafana-pod03, grafana-pod04, grafana-pod05,
    
    newrelic-svc01        -- cluster-IP ==> 10.8.0.0:80
    promethesus-svc01     -- cluster-IP ==> 10.9.0.0:80 
    grafana-svc01         -- cluster-IP ==> 10.10.0.0:80
]

logging-ns = [
   elasticsearch-pod01, elasticsearch-pod02, elasticsearch-pod03, elasticsearch-pod04, elasticsearch-pod05,
   logstach-pod01, logstach-pod02, logstach-pod03, logstach-pod04, logstach-pod05,
   kibana-pod01, kibana-pod02, kibana-pod03, kibana-pod04, kibana-pod05,     

   elasticsearch-svc01,      -- cluster-IP ==> 10.11.0.0:80
   logging-svc01,            -- cluster-IP ==> 10.12.0.0:80
   kibana-svc01,             -- cluster-IP ==> 10.13.0.0:80
]





apiVersion: v1
kind: Pod
metadata:
  name: pod-a
spec:
  containers:
  - name: web-app
    image: your-web-app-image
    ports:
    - containerPort: 8080




apiVersion: v1
kind: Pod
metadata:
  name: pod-b
spec:
  containers:
  - name: client-app
    image: your-client-app-image
    command: ["sleep", "infinity"]



apiVersion: v1
kind: Service
metadata:
  name: pod-service
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080



Test the Communication: To test the communication, you can access Pod B and send a request to Pod A using the service’s DNS name. Run the following command:


kubectl exec -it pod-b -- sh

curl pod-service


===========================  lmsapp --- api -->> ===============


apiVersion: v1
kind: Pod
metadata:
  name: lmspod01
  label:
    app: lmspod01
spec:
  replicas : 10
  containers:
  - name: lmspod01
    image: lms:v1
    ports:
    - containerPort: 8080

apiVersion: v1
kind: Service
metadata:
  name: lmspodsvc01
spec:
  selector:
    app: lmspod01
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080



apiVersion: v1
kind: Pod
metadata:
  name: mostapi
spec:
  containers:
  - name: mostapi
    image: mostapi:v1
    command: ["sleep", "infinity"]


kubectl exec -it mostapi-34234 -- /bin/bash

curl http://lmspodsvc01:80





apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-mostapi-all-traffic
spec:
  podSelector:
    matchLabels:
      app=mostapi
  ingress: []


kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: api-allow
spec:
  podSelector:
    matchLabels:
      app: bookstore
      role: api
  ingress:
  - from:
      - podSelector:
          matchLabels:
            app: bookstore



kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-all
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
      app: mostapi
      web: nginx
      db: mysql

  ingress:
  - {}



  Note: Empty ingress rule ({}) allows traffic from all pods in the current namespace, as well as other namespaces. It corresponds to:

    
- from:
- podSelector: {}
    namespaceSelector: {}




kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  ingress: []



kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: default
  name: deny-from-other-namespaces
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - podSelector: {}


kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-prod
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          purpose: production

Port Level Traffic Deny - Blocking

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: api-allow-5000
spec:
  podSelector:
    matchLabels:
      app: apiserver
  ingress:
  - ports:
    - port: 5000
    from:
    - podSelector:
        matchLabels:
          role: monitoring


Redis - DB allow -- Multiple applications / Multiple application traffic

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: redis-allow-services
spec:
  podSelector:
    matchLabels:
      app: bookstore
      role: db
      type: redis
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: bookstore
          role: search
    - podSelector:
        matchLabels:
          app: mostapi
          role: api
    - podSelector:
        matchLabels:
          app: inventory
          role: web



-----------------  END  Ingress -----------------------


=--------------------------------------------

Egress Traffic


apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: foo-deny-egress
spec:
  podSelector:
    matchLabels:
      app: foo
  policyTypes:
  - Egress
  egress: []       #  egress: [] empty rule set does not whitelist any traffic, therefore all egress (outbound) traffic is blocked




kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny-all-egress
  namespace: default
spec:
  policyTypes:
  - Egress
  podSelector: {}
  egress: []


Note a few things about this manifest:

namespace: default deploy this policy to the default namespace.
podSelector: is empty, this means it will match all the pods. Therefore, the policy will be enforced to ALL pods in the default namespace.
List of egress rules is an empty array: This causes all traffic (including DNS resolution) to be dropped if it’s originating from Pods in default.



DENY external egress traffic

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: foo-deny-external-egress
spec:
  podSelector:
    matchLabels:
      app: foo
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
      - port: 53
        protocol: UDP
      - port: 53
        protocol: TCP


