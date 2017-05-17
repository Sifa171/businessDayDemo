# JBoss Business Day 2017 - OpenShift in action
##### Based on Grant Shipleys MLB Parks example (https://github.com/gshipley/openshift3mlbparks)

This is a short demo of OpenShift 3, as part of the so called <b>Viada JBoss Business Day 2017</b> in Frankfurt.

This demo deals with development and operational issues too and takes roughly a hour.

 If you want to reuse this demo, just follow the [instructions][f1572854] explained at the bottom of the page.    
## Agenda
### Build and Deploy an image
  1. Source to Image
    - Explanation
    - MLB Parks Template
    - Logs
    - Influence build process
    - Defining Health Checks
  2. Docker Strategy
    - How to use Docker Images
    - Logs
  3. Deployment Strategies and configuration
    - Recreate
    - Rolling
  4. Configuration
    - Config Maps
    - Secrets

  [f1572854]: https://github.com/Sifa91/businessDayDemo#how-to-use-this-demo "How to"

### Failover Scenerios
  1. Pod crashes
  2. Liveness probe fails
  3. Readiness probe fails

### Logging & Debugging
  1. Debug Terminal
  2. Remote Debugging
  3. EFK

### Development Tools
  1. JBoss Tools
  2. oc cluster up
  3. minishift

### Q&A

## How to use this demo
To use this demo create a new project in your OpenShift 3 instance, switch into it and clone this repo.
```
oc new-project $PROJECTNAME
oc project $PROJECTNAME
git clone https://github.com/Sifa91/businessDayDemo.git
cd cd $PATH_TO_YOUR_CLONED_REPO
```
### Build and Deploy an image
1. Source to Image
  - For explanation just use [this][aa426728] presentation
  - First create the template in your project and process it
  ```
  oc create -f mlbparks-template-wildfly.json
  oc new-app --template=mlbparks-wildfly
  ```
  - To follow logs from any pod use
```
oc get pods
oc logs -f $POD_ID
```
  - You got the opportunity to influence the build process by adding a new directory in your root folder '.s2i/bin'
  ```
  mkdir -p .s2i/bin
  cp misc/scripts/assemble .s2i/bin/
  ```
  Now commit your changes and push them to your repo. Afterwards trigger a new build and follow the logs
  ```
  oc start-build mlbparks --follow
  ```
  - Now it is time to define some health checks and explain them. Be flexible! Show some scenerios by editing the DeploymentConfig live in the web interface
  ```
  oc replace -f misc/scripts/dc-with-health-checks.yaml
  ```

2. Docker Strategy<br>
<i>Imagine you would like to use an image just for analyze purposes, but you do not have one and there is no out of the box imag, which you could use. So you wrote your own one, tested it locally and want to use it as your analyze container in OpenShift now.</i>
  - Create a new ImageStream and BuildConfig, which uses docker strategy
  ```
  oc create -f misc/scripts/is-analyze-image.yaml
  oc create -f misc/scripts/bc-analyze-image.yaml
  ```
  - Now create a new build by using and have a look at the build log
  ```
  oc start-build analyze --follow
  ```
  - It is time to run your analyze container! But before you need to figure out which IP your registry has. You can copy it from the 'pull spec' in your ImageStream
  ```
  oc run analyze -it --image=$IMAGE_REGISTRY_IP/$PROJECTNAME/analyze --restart=Always
  ```
3. Deployment Strategies<br>
<i>Now it is time to explain the different kinds of deployment strategies based on the mlbparks DeploymentConfig. Start with 'Recreate'! Just do it live in the web interface</i>
  - If you finished explaining 'recreate' follow these steps and explain what exactly happens TODO: Maybe build a new version and push it to latest
  ```
  oc replace -f misc/scripts/dc-with-rolling-upgrade.yaml
  oc rollout latest dc/mlbparks
  ```
4. Configuration
  - If you would like to ENV multiple times, then you should use ConfigMaps
  ```
  oc create -f misc/scripts/config-map.yaml
  oc replace -f misc/scripts/dc-with-config-map.yaml
  ```
  Navigate to the terminal in the web interface or use 'oc rsh $POD_ID' to show the new ENVs.

  - In some cases you would like to use a confidential file inside of a Pod, which should not be stored unencrypted in the platform. It is time for secrets!
  ```
  oc create secret generic my-secret --from-file=misc/scripts/testfileforsecret.md
  oc replace -f misc/scripts/dc-with-secrets.yaml
  ```
  Navigate to the terminal in the web interface or use 'oc rsh $POD_ID' to show the mounted file.

### Failover Scenerios
1. Pod crashes
2. Liveness probe fails
3. Readiness probe fails

### Logging & Debugging
1. Debug Terminal
2. Remote Debugging
3. EFK

### Development Tools
1. JBoss Tools
2. oc cluster up
3. minishift

## Links

  [aa426728]: https://github.com/Sifa91/businessDayDemo/blob/master/misc/source-to-image.pdf "Source to Image"
