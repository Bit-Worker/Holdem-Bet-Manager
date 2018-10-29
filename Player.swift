//
//  Player.swift
//  BetManager
//
//  Created by Alessandro Vanni on 20/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

class Player: Hashable, CustomStringConvertible {
	
	// MARK: Properties
	
	let name: String
	
	var stack: Int = 0 {
		didSet {
			Print.log("\(name)'s stack set from \(oldValue) to \(stack)")
		}
	}
	
	// MARK: Computed properties
	
	var description: String {
		return "\(name) (\(stack))"
	}
	
	var isAllIn: Bool {
		return stack <= 0
	}
	
	// MARK: Initializers
	
	init(name: String) {
		self.name = name
	}
	
	// MARK: Methods
	
	@discardableResult func bet(amount bet: Int) -> BetResult {
		guard stack - bet >= 0 else {
			return .error(message: "Not enough chips", stack: stack)
		}
		stack -= bet
		return .success
	}
	
	// MARK: Hashable protocol
	
	static func == (lhs: Player, rhs: Player) -> Bool {
		return lhs.name == rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
	
}

// MARK: Bet enumeration

enum BetResult {
	case success, error(message: String, stack: Int)
}
