// Firebase Stubs - Temporary for building without Firebase
// Remove this file when Firebase is properly configured

import SwiftUI

// MARK: - Firebase Stub Classes
class FirebaseApp {
    static func configure() {}
}

class Auth {
    static func auth() -> Auth { return Auth() }
    func addStateDidChangeListener(_ listener: @escaping (Auth, User?) -> Void) -> AuthStateDidChangeListenerHandle {
        // Simulate logged in state for preview
        DispatchQueue.main.async {
            listener(self, User())
        }
        return AuthStateDidChangeListenerHandle()
    }
    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {}
    func signOut() throws {}
}

class AuthStateDidChangeListenerHandle {}

class User {
    var uid: String = "preview-user-id"
    var email: String? = "preview@modaics.com"
    var displayName: String? = "Preview User"
}

// MARK: - Firebase Messaging Stub
class Messaging {
    static func messaging() -> Messaging { return Messaging() }
    func delegate(_ delegate: Any?) {}
}

// MARK: - UNUserNotificationCenter Stub
class UNUserNotificationCenter {
    static func current() -> UNUserNotificationCenter { return UNUserNotificationCenter() }
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(true, nil)
    }
}

struct UNAuthorizationOptions: OptionSet {
    let rawValue: Int
    static let alert = UNAuthorizationOptions(rawValue: 1)
    static let badge = UNAuthorizationOptions(rawValue: 2)
    static let sound = UNAuthorizationOptions(rawValue: 4)
}

// MARK: - Typealiases for Firebase types
typealias FirebaseCore = Void
typealias FirebaseAuth = Void
typealias FirebaseMessaging = Void
