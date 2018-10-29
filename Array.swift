//
//  Array.swift
//  BetManager
//
//  Created by Alessandro Vanni on 07/10/2018.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

extension Array where Element == Player {
	
	func set(stack: Int) -> Void {
		self.forEach() { player in
			player.stack = stack
		}
	}
	
	func get(after chosen: Player, excluding excluded: Set<Player> = []) -> Player? {
		if self.count < 2 {
			return nil
		}
		for (var index, player) in self.enumerated() {
			if player == chosen {
				repeat {
					index = index + 1 < self.endIndex ? index + 1 : 0
				} while excluded.contains(self[index])
				return self[index]
			}
		}
		return nil
	}
	
	func get(before chosen: Player, excluding excluded: Set<Player> = []) -> Player? {
		if self.count < 2 {
			return nil
		}
		for (var index, player) in self.enumerated() {
			if player == chosen {
				repeat {
					index = index >= 1  ? index - 1 : self.endIndex - 1
				} while excluded.contains(self[index])
				return self[index]
			}
		}
		return nil
	}
	
	func contains(name: String) -> Bool {
		return self.contains() { player in
			player.name == name
		}
	}
	
	func find(named name: String) -> Player? {
		for player in self where player.name == name {
			return player
		}
		return nil
	}
	
}

extension Array where Element == String {
	var printed: String {
		switch count {
		case 0:
			return ""
		default:
			var result = "'\(first!)'"
			for string in self {
				switch string {
				case first!:
					break
				case last!:
					result += " or '\(string)'"
				default:
					result += ", '\(string)'"
				}
			}
			return result
		}
	}
}
