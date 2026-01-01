//
//  KeychainManager.swift
//  GemNote
//
//  Secure storage for API keys and sensitive data
//

import Foundation
import Security

/// Manager for securely storing and retrieving sensitive data using Keychain
final class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.gemnote.app"
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Store a string value in the keychain
    func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw GemNoteError.dataNotFound
        }
        
        // Delete any existing item
        try? delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw GemNoteError.dataNotFound
        }
    }
    
    /// Retrieve a string value from the keychain
    func retrieve(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete a value from the keychain
    func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw GemNoteError.dataNotFound
        }
    }
    
    // MARK: - Convenience Methods for API Key
    
    private let apiKeyKey = "gemini_api_key"
    
    var geminiAPIKey: String? {
        get { retrieve(apiKeyKey) }
        set {
            if let value = newValue {
                try? save(value, for: apiKeyKey)
            } else {
                try? delete(apiKeyKey)
            }
        }
    }
}
