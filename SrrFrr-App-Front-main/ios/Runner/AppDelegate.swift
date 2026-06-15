import UIKit
import Flutter
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()
    
    // Initialize Google Maps with your API key
    GMSServices.provideAPIKey("YOUR_IOS_GOOGLE_MAPS_API_KEY_HERE")
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle notification registration
  override func application(_ application: UIApplication, 
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Pass device token to Firebase
    Messaging.messaging().apnsToken = deviceToken
  }
}