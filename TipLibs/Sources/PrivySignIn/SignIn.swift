//
//  File.swift
//  
//
//  Created by Christian Ray Leovido on 13/09/2024.
//

import Foundation
import PrivySDK

public final class PrivyClient: Observable, ObservableObject {
	public let config: PrivyConfig
	public let privy: Privy
	
	@Published var myAuthState: AuthState = .notReady

	public init() {
		self.config = PrivyConfig(appId: "cm111cwwg02gc7nq000vajjeu", appClientId: "client-WY5bdwaHwgDpv52Y69XKFMZxYDNV1kJRxD5YuCu4rgntB")
		self.privy = PrivySdk.initialize(config: config)
		
		privy.setAuthStateChangeCallback { state in
			// Logic to execute after there is an auth change.
			self.myAuthState = state
		}
		
		privy.siwe.setSiweFlowStateChangeCallback({ siweFlowState in
			switch siweFlowState {
			case .initial:
				// Starting state
				break
			case .generatingMessage:
				// SIWE message being created
				break
			case .awaitingSignature:
				// Waiting for you to pass the signature generated from the personal_sign request
				break
			case .submittingSignature:
				// Submitted signature to authenticate
				break
			case .done:
				// Complete
				break
			case .error:
				// An error has occurred
				break
			@unknown default:
				fatalError()
			}
		})
	}
}
