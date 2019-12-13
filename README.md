# Install

If you dont have cocoapods installed on your maching

```shell
sudo gem install cocoapods
```

Once you have cocoapods installed cd into your project. If you don't have cocoapods initalized you can init like this

```shell
pod init
```

Now, open the generated podfile and add this project

```ruby
pod 'iOSRawCamera'
```

Finally, install or update the dependencies.

```shell
pod install
```

Now use the workspace file to open xCode.

Basic Usage

Check camera authorization like this:

```swift
let authorizationController = CameraAuthorizationController()

guard authorizationController.isCameraAuthorized() == true else {
    return
}
```

Request camera authorization like this:

```swift
let cameraAuthorizationController = CameraAuthorizationController()
cameraAuthorizationController.requestCameraPermission { (didAuthorize) in
    switch didAuthorize {
    case true:
        break
    case false:
        break
    }
}
```

Once authorized, you can set up the camera synchronously or asynchronously

Sync:

```swift
let cameraController: CameraController = CameraController()
do{
    try cameraController.setUp()
}catch{

}
```

Async:

```swift
let cameraController: CameraController = CameraController()
let asyncController = CameraAsyncController()
asyncController.setUpAsync(cameraController: cameraController, finished: { (p_error) in
    if let error = p_error {
        callback?(error)
    }else {
        callback?(nil)
    }
})
```

Once the camera is set up you can start it like this:

```swift
cameraController.startRunning()
```

Then, all your objects that want to get `CVPixelBuffer`'s can listen for the notification like this:

```swift
NotificationCenter.default.addObserver(self, selector: #selector(self.newBuffer(_:)), name: NewCameraBufferNotification, object: nil)
@objc func newBuffer(_ notification: Notification) {
    let buffer = notification.object as! CVPixelBuffer
    let w = Int32(CVPixelBufferGetWidth(buffer))
    let h = Int32(CVPixelBufferGetHeight(buffer))
    let opaque = UnsafeMutableRawPointer(Unmanaged.passRetained(buffer).toOpaque())
    CVPixelBufferLockBaseAddress(buffer, .readOnly)
    //Do inference.
    CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
}
```
