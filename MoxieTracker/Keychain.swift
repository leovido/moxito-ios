import Foundation
import Security
import Sentry

enum KeychainError: Error {
	case message(String)
}

func saveToKeychain(token: String, for account: String, service: String) {
	let tokenData = token.data(using: .utf8)!
	let query = [
		kSecClass: kSecClassGenericPassword,
		kSecAttrAccount: account,
		kSecAttrService: service,
		kSecValueData: tokenData
	] as CFDictionary
	SecItemAdd(query, nil)
}

func retrieveFromKeychain(account: String, service: String) -> String? {
	let query = [
		kSecClass: kSecClassGenericPassword,
		kSecAttrAccount: account,
		kSecAttrService: service,
		kSecReturnData: true,
		kSecMatchLimit: kSecMatchLimitOne
	] as CFDictionary

	var dataTypeRef: AnyObject?
	let status = SecItemCopyMatching(query, &dataTypeRef)

	if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
		return String(data: retrievedData, encoding: .utf8)
	}
	return nil
}

func deleteKeychainItem(service: String, account: String) -> Bool {
	let query: [String: Any] = [
		kSecClass as String: kSecClassGenericPassword,
		kSecAttrService as String: service,
		kSecAttrAccount as String: account
	]

	let status = SecItemDelete(query as CFDictionary)

	if status == errSecSuccess {
		SentrySDK.capture(error: KeychainError.message("Keychain item successfully deleted"))

		return true
	} else if status == errSecItemNotFound {
		SentrySDK.capture(error: KeychainError.message("Keychain item not found"))

		return false
	} else {
		SentrySDK.capture(error: KeychainError.message("Error deleting keychain item: \(status)"))
		return false
	}
}
