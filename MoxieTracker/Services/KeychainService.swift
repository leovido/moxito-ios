import Foundation
import Security

enum KeychainError: Error {
	case message(String)
}

final class KeychainService: KeychainProvider {
	func save(token: String, for account: String, service: String) throws {
		guard let tokenData = token.data(using: .utf8) else {
			throw KeychainError.message("Invalid token data")
		}

		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: account,
			kSecAttrService as String: service,
			kSecValueData as String: tokenData
		]

		// First try to add the item
		var status = SecItemAdd(query as CFDictionary, nil)

		// If item already exists, update it instead
		if status == errSecDuplicateItem {
			let updateQuery: [String: Any] = [
				kSecClass as String: kSecClassGenericPassword,
				kSecAttrAccount as String: account,
				kSecAttrService as String: service
			]

			let attributes: [String: Any] = [
				kSecValueData as String: tokenData
			]

			status = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
		}

		guard status == errSecSuccess else {
			throw KeychainError.message("Failed to save token: \(status)")
		}
	}

	func retrieve(account: String, service: String) throws -> String? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: account,
			kSecAttrService as String: service,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		var dataTypeRef: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

		guard status != errSecItemNotFound else {
			return nil
		}

		guard status == errSecSuccess else {
			throw KeychainError.message("Failed to retrieve token: \(status)")
		}

		guard let retrievedData = dataTypeRef as? Data,
					let token = String(data: retrievedData, encoding: .utf8) else {
			throw KeychainError.message("Failed to decode token data")
		}

		return token
	}

	func delete(service: String, account: String) throws {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account
		]

		let status = SecItemDelete(query as CFDictionary)

		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw KeychainError.message("Failed to delete token: \(status)")
		}
	}
}
