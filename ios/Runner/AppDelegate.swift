import UIKit
import Flutter
import Mobileproxy

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var proxy: MobileproxyProxy?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let channel = FlutterMethodChannel(name: "sample.example.com/proxy",
                                               binaryMessenger: controller.binaryMessenger)
            channel.setMethodCallHandler({
                (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                // This method is invoked on the UI thread.
                // Handle Flutter calling messages.
                if call.method == "startOutlineProxy" {
                    let args = call.arguments as? [String: Any]
                    let port = args?["port"] as? String?
                    let key = args?["key"] as? String?
                    self.proxy = MobileproxyRunProxy("localhost:"+port!!,
                                                     MobileproxyNewStreamDialerFromConfig(key!!, nil), nil
                    );
                    result(self.proxy?.address())
                } else if call.method == "stopOutlineProxy" {
                    self.proxy?.stop(0)
                    result("Proxy stopped successfully")
                } else {
                    result(FlutterMethodNotImplemented)
                }
            })
            
            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    
    //   stop proxy when app is terminated
    override func applicationWillTerminate(_ application: UIApplication) {
        self.proxy?.stop(0)
    }
}
