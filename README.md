![](http://cl.ly/47422U3i172J)


# FASTLANE INTEGRATION:

1- WHAT IS FASTLANE

- Fastlane includes several tools to make usual actions when developing apps.  Those actions can be building, running tests, install pods, upload to appstore...

- Those tools (from now on called 'ACTIONS') are highly configurable.  Here's a list of available actions ( https://github.com/fastlane/fastlane/blob/master/docs/Actions.md )



2- HOW FASTLANE WORKS

- First of all fastlane must be installed.  Open terminal, go to your project folder and type :  "sudo gem install fastlane --verbose"

	- If It's a new project you should setup fastlane, follow the steps on this link: https://github.com/fastlane/fastlane/blob/master/docs/Guide.md#setting-up-fastlane

	- If teh project is already using fastlane, there's no need for setup

- Once fastlane is installed and setted up, the project will include a "/fastlane" folder, inside this folder we can find the "Fastfile" where we will create all the sets of actions that we want to run (those sets of actions are called 'LANES').

Lane example:

Let's say we want to upload a build to crashlytics:

The lane could look like this:

desc "Build and distribute build to Crashlytics"
  lane :beta do
    
    gym(scheme: "MyApp", workspace: "MyApp.xcworkspace")

    crashlytics(
  		crashlytics_path: './Crashlytics.framework',
  		api_token: '123456',
	  	build_secret: 'abcdefghijklmnop'
	)
  end

this 'beta' lane has 2 actions: 'gym' (builds the archive) and 'crashlytics' uploads this archive to test.


- To call any lane we should just type "fastlane 'lane_name' " in the console, and this will automatically run all the actions in the lane.  In the example we should execute "fastlane beta". [IMPORTANT: in order to let the crashlytics action upload the archive automatically, the crashlytics mac app, should not be running in the computer at the moment.  If is running will 'intercept' the archive and try to distribute manually]

- There are two special methods in the Fastfile: "before_all" and "after_all".  Whatever is inside those methods will be executed (... guess what...) before and after any lane

before_all do
    cocoapods
    increment_build_number
  end

after_all do |lane|
    notify "Fastlane finished '#{lane}' successfully" # Mac OS X Notification
  end


- Finally, there's another method called when the executed lane fails ("error"):

error do |lane, exception|
 	puts "exception: #{exception.message}"
  end


For more detailed info check:

https://github.com/fastlane/fastlane/tree/master/docs
https://github.com/fastlane/examples


