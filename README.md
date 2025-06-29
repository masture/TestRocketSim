# TestRocketSim


This is a sample app that uses the front-facing camera of your Mac to simulate an iPhone. It captures images and displays them in a horizontal scroll view at the bottom.

This app is designed to test and demonstrate the new feature of [RocketSim App](https://www.rocketsim.app/).
It enables using the Mac’s HD FaceTime camera as the iPhone simulator’s camera.

It works like a charm! The integration is super simple.

Here’s how you can do it:

1. Add the following function to your AppDelegate and call it from the `didFinishLaunchingWithOptions` function.

```
private func loadRocketSimConnect() {
#if DEBUG
        guard (Bundle(path: “/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework”)?.load() == true) else {
            print(“Failed to load linker framework”)
            return
        }
        print(“RocketSim Connect successfully linked”)
#endif
    }
```

2. As you can see, the entire body of the function is wrapped in `# if DEBUG`. This means it won’t be shipped with your app.

  
