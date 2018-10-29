//
//  Game.swift
//  BetManager
//
//  Created by Alessandro Vanni on 20/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

class Game {
	
	deinit {
		Print.log("Game deinit")
	}
	
	// MARK: Properties
	
	var players: [Player] = []
	var uniqueNames: Set<String> = []
	
	// MARK: Computed properties
	
	var ready: Bool {
		return players.count > 1
	}
	
	var hasWinner: Bool {
		return players.filter() { player in
			player.stack > 0
		}.count == 1
	}
	
	var winner: Player? {
		let inGamePlayers = players.filter() { player in
			player.stack > 0
		}
		if inGamePlayers.count > 1 {
			return nil
		} else {
			return inGamePlayers.first
		}
	}
	
	// MARK: Methods
	
	func add(player: String) -> OperationResult {
		let name = player.uppercased()
		guard !uniqueNames.contains(name) else {
			return .error(message: "[\(name)] is not an unique name")
		}
		uniqueNames.insert(name)
		players.append(Player(name: name))
		return .success(message: "Player \(name) successfully added")
	}
	
	// MARK: Enumerations
	
	enum OperationResult {
		case success(message: String), error(message: String)
	}
	
}

