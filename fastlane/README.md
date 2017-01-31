fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Will clone develop, create a new `release-x.x.x` branch from, update the build info, push it and do a deploy of that to crashlytics
### ios beta
```
fastlane ios beta
```
Will clone the specified branch, update the build info and do a deploy of that to crashlytics
### ios local_beta
```
fastlane ios local_beta
```
Build and distribute local code to Crashlytics
### ios deploy_to_appstore
```
fastlane ios deploy_to_appstore
```
Deploys a new version to App Store
### ios strings
```
fastlane ios strings
```
Will update Web Translate It with the new validated strings from google drive, download all the changes from wti and generate all not-yet valid strings on base + localizables file
### ios bumper
```
fastlane ios bumper
```
Will generate BumperFlags.switf based on the sources json
### ios test
```
fastlane ios test
```
Will test
### ios ci
```
fastlane ios ci
```
Will run CI

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
