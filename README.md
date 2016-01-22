![](http://cl.ly/47422U3i172J/letgo-ios-logo.png)


### :space_invader: FASTLANE INTEGRATION:

#### WHAT IS FASTLANE

- Fastlane includes several tools to make usual actions when developing apps.  Those actions can be building, running tests, install pods, upload to appstore...

- Those tools (from now on called 'ACTIONS') are highly configurable.  Here's a list of available actions ( https://github.com/fastlane/fastlane/blob/master/docs/Actions.md )



#### HOW FASTLANE WORKS

- First of all fastlane must be installed.  Open terminal, go to your project folder and type :  "sudo gem install fastlane --verbose"

  - If It's a new project you should setup fastlane, follow the steps on this link: https://github.com/fastlane/fastlane/blob/master/docs/Guide.md#setting-up-fastlane

  - If teh project is already using fastlane, there's no need for setup

- Once fastlane is installed and setted up, the project will include a "/fastlane" folder, inside this folder we can find the "Fastfile" where we will create all the sets of actions that we want to run (those sets of actions are called 'LANES').


**Lane example:**

Let's say we want to upload a build to crashlytics, the lane could look like this:

```ruby
desc "Build and distribute build to Crashlytics"
lane :beta do

gym(scheme: "MyApp", workspace: "MyApp.xcworkspace")

crashlytics(
  crashlytics_path: './Crashlytics.framework',
  api_token: '123456',
  build_secret: 'abcdefghijklmnop'
)
end
```

This `beta` lane has 2 actions: `gym` (builds the archive) and `crashlitycs` uploads this archive to test.


- To call any lane we should just type `fastlane 'lane_name'` in the console, and this will automatically run all the actions in the lane.  In the example we should execute `fastlane beta`. [IMPORTANT: in order to let the crashlytics action upload the archive automatically, the crashlytics mac app, should not be running in the computer at the moment.  If is running will 'intercept' the archive and try to distribute manually]

- There are two special methods in the Fastfile: `before_all` and `after_all`.  Whatever is inside those methods will be executed (... guess what...) before and after any lane

```ruby
before_all do
  cocoapods

  increment_build_number
end

after_all do |lane|
  notify "Fastlane finished '#{lane}' successfully" # Mac OS X Notification
end
```

- Finally, there's another method called when the executed lane fails ("error"):

```ruby
error do |lane, exception|
  puts "exception: #{exception.message}"
end
```


For more detailed info check:

https://github.com/fastlane/fastlane/tree/master/docs

https://github.com/fastlane/examples


#### LETGO LANES:

**release**

  - clone develop
  - create new branch from develop with name `release-x.x.x`
  - update version_number if needed
  - Increment build number by 1
  - Build release branch
  - Push changes to remote
  - Upload build to crashlitycs

**beta**

  - select branch to build
  - clone branch
  - update version_number if needed
  - Increment build number by 1
  - Build release branch
  - Push changes to remote
  - Upload build to crashlitycs

**deploy_to_appstore**

  - select release branch `release-x.x.x`
  - clone `master` branch
  - merge `release-x.x.x` into `master`
  - build `master`
  - upload build to app store


### Compiler directives

On schemes `LetGoDEV` and `LetGoPROD` there's a `GOD_MODE` compiler directive. We're using that directive to enable a new field on system settings to choose api environment. Those are the following selectable environments:

- **Production**:   Production api + production keys
- **Canary**: Canary api + production keys
- **Staging**: Staging api + development keys

*The usage of `GOD_MODE`can be checked on `EnvironmentsHelper.swift` class


#### Do not use those schemes to publish to appstore!