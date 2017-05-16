# JBoss Business Day 2017 - OpenShift in action
##### Based on Grant Shipleys MLB Parks example (https://github.com/gshipley/openshift3mlbparks)

This is a short demo of OpenShift 3, as part of the so called <b>Viada JBoss Business Day 2017</b> in Frankfurt.

The demo deals with development and operational issues too.

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
  3. Deployment Strategies
    - Recreate
    - Rolling

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
  oc create -f mlbparks-template-eap.json
  oc new-app --template=mlbparks-eap
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


  [aa426728]: https://github.com/Sifa91/businessDayDemo/blob/master/misc/source-to-image.pdf "Source to Image"
