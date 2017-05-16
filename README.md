# JBoss Business Day 2017 - OpenShift in der Praxis
##### Based on Grant Shipleys MLB Parks example (https://github.com/gshipley/openshift3mlbparks)

This is a short demo of OpenShift 3, for the so called <b>Viada JBoss Business Day 2017</b> in Frankfurt.

The demo deals with development and operational issues too.

 If you want to reuse this demo, just follow the instructions explained at the bottom of the page.    
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
oc new-project $Projectname
oc project $Projectname
git clone https://github.com/Sifa91/businessDayDemo.git
```
### Build and Deploy an image
1. Source to Image
  - For explanation just use [this][aa426728] presemtation
  - First create the template in your project and process it
  ```
  oc create -f https://github.com/Sifa91/businessDayDemo/blob/master/mlbparks-template-eap.json
  oc new-app --template=mlbparks-eap
  ```
  - To follow logs from any pod use
```
oc get pods
oc logs -f $POD_ID
```
  - You got the opportunity to influence the build process by adding a new directory in your root folder '.s2i/bin'
  ```
  cd $PATH_TO_YOUR_CLONED_REPO
  mkdir -p .s2i/bin
  cp misc/scripts/assemble .s2i/bin/
  ```
  Now commit your changes and push them to your repo. Afterwards trigger a new build and follow the logs
  ```
  oc start-build mlbparks --follow
  ```


  [aa426728]: https://github.com/Sifa91/businessDayDemo/blob/master/misc/source-to-image.pdf "Source to Image"
