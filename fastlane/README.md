fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>
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
### ios update_cars_info
```
fastlane ios update_cars_info
```
Copy CarsInfo json from remote host
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
Will unit test
### ios ui_test
```
fastlane ios ui_test
```
Will UI test
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


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
