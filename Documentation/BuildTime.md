#### Build Time Analizer

[Build Time Analyzer](https://github.com/RobertGummesson/BuildTimeAnalyzer-for-Xcode) is a macOS app that shows you a break down of Swift build times.

 Usage:

1. git clone https://github.com/RobertGummesson/BuildTimeAnalyzer-for-Xcode
2. Open project with Xcode and run it
3. Follow app instructions.

#### Show build time in Xcode

Type this in terminal:
~~~
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
~~~
Duration appears in the activity viewer after a build, alongside the "Succeeded" message.

Note: If you are running the app, the status will be replaced by the running status before you can see the duration.

#### Best practices

[Swift build time optimizations](https://medium.com/@RobertGummesson/regarding-swift-build-time-optimizations-fc92cdd91e31#.4py75x8ho)
[Swift build time optimizations part2](https://medium.com/swift-programming/swift-build-time-optimizations-part-2-37b0a7514cbe#.i2vnfq20e)


