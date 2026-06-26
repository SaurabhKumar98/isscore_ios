import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

override func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

// ✅ Initialize Firebase
FirebaseApp.configure()

// ✅ Register Flutter plugins
GeneratedPluginRegistrant.register(with: self)

// ✅ Request notification permission
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self
  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
  UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: { _, _ in }
  )
} else {
  application.registerUserNotificationSettings(
    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
  )
}

application.registerForRemoteNotifications()

return super.application(application, didFinishLaunchingWithOptions: launchOptions)

}

// ✅ APNS Token
override func application(
_ application: UIApplication,
didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}

}
