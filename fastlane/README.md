fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Will clone master, create a new `release-x.x.x` branch from, update the build info, push it and do a deploy of that to crashlytics
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
### ios strings
```
fastlane ios strings
```
Will update Web Translate It with the new validated strings from google drive, download all the changes from wti and generate all not-yet valid strings on base + localizables file
### ios strings_clean
```
fastlane ios strings_clean
```
Updates strings with wti and cleans un-used ones, then removes the un-used keys from code
### ios assets_clean
```
fastlane ios assets_clean
```
Clean un-used assets
### ios clean
```
fastlane ios clean
```
Clean project
### ios update_dsyms
```
fastlane ios update_dsyms
```
Download all the given dSYM symbolication files from iTunes Connect and upload them to crashlytics.
### ios bumper
```
fastlane ios bumper
```
Will generate BumperFlags.switf based on the sources json
### ios test
```
fastlane ios test
```
Will unit test
### ios ciJenkins
```
fastlane ios ciJenkins
```
Will run CI on Jenkins
### ios ci
```
fastlane ios ci
```
Will run CI unit tests job
### ios ci_ui_tests
```
fastlane ios ci_ui_tests
```
Will run CI UI tests job
### ios dependencies
```
fastlane ios dependencies
```

### ios upload_crashlytics
```
fastlane ios upload_crashlytics
```
Upload beta build to crashlytics
### ios build_beta
```
fastlane ios build_beta
```
Does a beta build
### ios build_appstore
```
fastlane ios build_appstore
```
Does an appstore build
### ios build_sim
```
fastlane ios build_sim
```
Does a simulator build
### ios test_shit
```
fastlane ios test_shit
```
testing
### ios write
```
fastlane ios write
```
testing2

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
