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
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios build_for_testing
```
fastlane ios build_for_testing
```
Install dependencies and build application for testing. Do not run tests.
### ios run_application_tests
```
fastlane ios run_application_tests
```
Perform unit and UI testing
### ios build_and_test
```
fastlane ios build_and_test
```
Restores Pods, build project and run tests. Sends notification to Discord on success. On error includes lane and error text

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
