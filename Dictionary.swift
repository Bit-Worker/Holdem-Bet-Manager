//
//  Dictionary.swift
//  BetManager
//
//  Created by Alessandro Vanni on 11/10/2018.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

extension Dictionary where Key == Player, Value == Int {
	
	var max: Int {
		let values = Array(self.values)
		return values.max() ?? 0
	}
	
	var total: Int {
		var total = 0
		for bet in self where bet.key.name != "Blind" {
			total += bet.value
		}
		return total
	}
	
}

extension Dictionary where Key == Player, Value == PotLimit {
	
	var minimumLimit: PotLimit {
		var result: PotLimit = .unlimited
		for potLimit in Array(self.values) {
			switch (potLimit, result) {
			case (.limited(let amount), .unlimited):
				result = .limited(to: amount)
			case (.limited(let amount), .limited(let limit)) where amount < limit:
				result = .limited(to: amount)
			default:
				break
			}
		}
		return result
	}
	
	var maximumLimit: PotLimit {
		var result: PotLimit = .limited(to: 0)
		for potLimit in Array(self.values) {
			switch (potLimit, result) {
			case (.unlimited, _):
				return .unlimited
			case (.limited(let amount), .limited(let limit)) where amount > limit:
				result = .limited(to: amount)
			default:
				break
			}
		}
		return result
	}
	
}
