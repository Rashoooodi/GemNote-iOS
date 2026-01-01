//
//  KeychainManager.swift
//  GemNote
//
//  Secure storage for sensitive data using iOS Keychain.
//

import Foundation
import Security

/// Manages secure storage of API keys and other sensitive data
final class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    private let service = "com.gemnote.app"
    
    // MARK: - Public Methods
    
    /// Save a string value to the Keychain
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Delete any existing value first
        try? delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// Retrieve a string value from the Keychain
    func retrieve(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.retrieveFailed(status)
        }
        
        return string
    }
    
    /// Delete a value from the Keychain
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

// MARK: - Keychain Error

enum KeychainError: LocalizedError {
    case invalidData
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .saveFailed(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve from Keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain (status: \(status))"
        }
    }
}

// MARK: - Constants

extension KeychainManager {
    enum Keys {
        static let geminiAPIKey = "gemini_api_key"
    }
}
