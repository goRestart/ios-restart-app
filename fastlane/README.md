fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios changelog
```
fastlane ios changelog
```

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
### ios deploy_to_appstore
```
fastlane ios deploy_to_appstore
```
Deploys a new version to App Store
### ios upload_strings
```
fastlane ios upload_strings
```
Will update Web Translate It with the new strings from google drive and then download all the changes from wti
### ios download_strings
```
fastlane ios download_strings
```
Will download all the changes from wti but without missing the last changes from google drive.
### ios generate_strings
```
fastlane ios generate_strings
```
Will just generate the base + english from google drive, won't touch anything on Wti

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools)
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane)