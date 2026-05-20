import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Keep the device from idling/sleeping while the app runs
    UIApplication.shared.isIdleTimerDisabled = true
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
