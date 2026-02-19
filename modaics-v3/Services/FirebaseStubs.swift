// MARK: - Firebase Stubs (Temporary)
// Remove this file once Firebase is properly installed via Swift Package Manager

import Foundation

// MARK: - Firebase Core Stubs
class FirebaseApp {
    static func configure() {}
}

// MARK: - Firebase Auth Stubs
class Auth {
    static func auth() -> Auth { return Auth() }
    var currentUser: FirebaseUser? { return nil }
    
    func signIn(withEmail email: String, password: String) async throws -> AuthResult {
        throw NSError(domain: "FirebaseStub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
    }
    
    func createUser(withEmail email: String, password: String) async throws -> AuthResult {
        throw NSError(domain: "FirebaseStub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
    }
}

class AuthResult {
    var user: FirebaseUser { return FirebaseUser() }
}

class FirebaseUser {
    var uid: String { return UUID().uuidString }
    var displayName: String? { return nil }
    var email: String? { return nil }
    var photoURL: URL? { return nil }
}

// MARK: - Firebase Messaging Stubs
class Messaging {
    static func messaging() -> Messaging { return Messaging() }
    var delegate: MessagingDelegate?
    func token() async throws -> String {
        throw NSError(domain: "FirebaseStub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
    }
}

protocol MessagingDelegate: AnyObject {}

// MARK: - Auth State Listener Handle Stub
typealias AuthStateDidChangeListenerHandle = String

// MARK: - Firebase Auth Stub Helpers
// AuthServiceProtocol is defined in Services.swift