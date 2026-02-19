import UIKit
#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
#endif
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase (if available)
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        
        // Configure Push Notifications
        configurePushNotifications(application)
        
        // Configure Deep Links
        configureDeepLinks()
        
        return true
    }
    
    // MARK: - Push Notifications
    private func configurePushNotifications(_ application: UIApplication) {
        // Set messaging delegate
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
        
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { granted, error in
            if let error = error {
                print("Push notification authorization error: \(error.localizedDescription)")
            }
            print("Push notification permission granted: \(granted)")
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
        print("Successfully registered for remote notifications")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - Deep Links
    private func configureDeepLinks() {
        // Deep link handling is done in ContentView via onOpenURL
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleDeepLink(url)
    }
    
    private func handleDeepLink(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return false
        }
        
        print("Handling deep link: \(url.absoluteString)")
        
        // Handle modaics:// links
        switch host {
        case "garment", "story", "user", "wardrobe":
            // Post notification for the app to handle
            NotificationCenter.default.post(
                name: .deepLinkReceived,
                object: nil,
                userInfo: ["url": url]
            )
            return true
        default:
            return false
        }
    }
    
    // MARK: - Background Fetch
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Perform background sync
        BackgroundSyncManager.shared.performSync { result in
            completionHandler(result)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([[.banner, .sound, .badge]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap
        if let deepLink = userInfo["deepLink"] as? String,
           let url = URL(string: deepLink) {
            handleDeepLink(url)
        }
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate
#if canImport(FirebaseMessaging)
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        // Send token to backend
        if let token = fcmToken {
            NotificationCenter.default.post(
                name: .fcmTokenReceived,
                object: nil,
                userInfo: ["token": token]
            )
        }
    }
}
#endif

// MARK: - Notification Names
extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
    static let fcmTokenReceived = Notification.Name("fcmTokenReceived")
}

// MARK: - Background Sync Manager
class BackgroundSyncManager {
    static let shared = BackgroundSyncManager()
    
    private init() {}
    
    func performSync(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        let syncGroup = DispatchGroup()
        var syncSuccessful = true
        
        // Sync wardrobe data
        syncGroup.enter()
        syncWardrobe { success in
            if !success { syncSuccessful = false }
            syncGroup.leave()
        }
        
        // Sync pending uploads
        syncGroup.enter()
        syncPendingUploads { success in
            if !success { syncSuccessful = false }
            syncGroup.leave()
        }
        
        syncGroup.notify(queue: .main) {
            completion(syncSuccessful ? .newData : .failed)
        }
    }
    
    private func syncWardrobe(completion: @escaping (Bool) -> Void) {
        // Implementation would sync with backend
        completion(true)
    }
    
    private func syncPendingUploads(completion: @escaping (Bool) -> Void) {
        // Implementation would retry failed uploads
        completion(true)
    }
}