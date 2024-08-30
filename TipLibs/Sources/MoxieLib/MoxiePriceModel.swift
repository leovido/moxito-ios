// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let moxiePrice = try? JSONDecoder().decode(MoxiePrice.self, from: jsonData)

import Foundation

// MARK: - MoxiePrice
public struct MoxiePrice: Codable {
	public let schemaVersion: String
	public let pairs: [Pair]
	public let pair: Pair
	
	public init(schemaVersion: String, pairs: [Pair], pair: Pair) {
		self.schemaVersion = schemaVersion
		self.pairs = pairs
		self.pair = pair
	}
}

// MARK: - Pair
public struct Pair: Codable {
	public let chainID, dexID: String
	public let url: String
	public let pairAddress: String
	public let labels: [String]
	public let baseToken, quoteToken: EToken
	public let priceNative, priceUsd: String
	public let txns: Txns
	public let volume, priceChange: PriceChange
	public let liquidity: Liquidity
	public let fdv, pairCreatedAt: Int
	
	public enum CodingKeys: String, CodingKey {
		case chainID = "chainId"
		case dexID = "dexId"
		case url, pairAddress, labels, baseToken, quoteToken, priceNative, priceUsd, txns, volume, priceChange, liquidity, fdv, pairCreatedAt
	}
	
	public init(chainID: String, dexID: String, url: String, pairAddress: String, labels: [String], baseToken: EToken, quoteToken: EToken, priceNative: String, priceUsd: String, txns: Txns, volume: PriceChange, priceChange: PriceChange, liquidity: Liquidity, fdv: Int, pairCreatedAt: Int) {
		self.chainID = chainID
		self.dexID = dexID
		self.url = url
		self.pairAddress = pairAddress
		self.labels = labels
		self.baseToken = baseToken
		self.quoteToken = quoteToken
		self.priceNative = priceNative
		self.priceUsd = priceUsd
		self.txns = txns
		self.volume = volume
		self.priceChange = priceChange
		self.liquidity = liquidity
		self.fdv = fdv
		self.pairCreatedAt = pairCreatedAt
	}
}

// MARK: - EToken
public struct EToken: Codable {
	public let address, name, symbol: String
	
	public init(address: String, name: String, symbol: String) {
		self.address = address
		self.name = name
		self.symbol = symbol
	}
}

// MARK: - Liquidity
public struct Liquidity: Codable {
	public let usd: Double
	public let base, quote: Int
	
	public init(usd: Double, base: Int, quote: Int) {
		self.usd = usd
		self.base = base
		self.quote = quote
	}
}

// MARK: - PriceChange
public struct PriceChange: Codable {
	public let h24, h6, h1, m5: Double
	
	public init(h24: Double, h6: Double, h1: Double, m5: Double) {
		self.h24 = h24
		self.h6 = h6
		self.h1 = h1
		self.m5 = m5
	}
}

// MARK: - Txns
public struct Txns: Codable {
	let m5, h1, h6, h24: H1
	
	public init(m5: H1, h1: H1, h6: H1, h24: H1) {
		self.m5 = m5
		self.h1 = h1
		self.h6 = h6
		self.h24 = h24
	}
}

// MARK: - H1
public struct H1: Codable {
	public let buys, sells: Int
	
	public init(buys: Int, sells: Int) {
		self.buys = buys
		self.sells = sells
	}
}
