//
//  Round.swift
//  BetManager
//
//  Created by Alessandro Vanni on 20/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

class Round {
	
	// MARK: Properties
	
	deinit {
		Print.log("Round deinit")
	}
	
	var game: Game
	var allIns: [Player: AllInState] = [:]
	var folded: Set<Player> = []
	let blinds: (big: Int, small: Int)
	
	var dealer: Player {
		didSet {
			Print.message("Dealer \(dealer.name), Small Blind \(halfBlinded.name), Big Blind \(fullBlinded.name)")
		}
	}
	
	init(game: Game, dealer: Player, blinds: (big: Int, small: Int)) {
		self.game = game
		self.dealer = dealer
		self.blinds = blinds
		Print.message("Dealer \(dealer.name), Small Blind \(halfBlinded.name), Big Blind \(fullBlinded.name)")
	}
	
	// MARK: Computed properties
	
	var halfBlinded: Player {
		return game.players.get(after: dealer)!
	}
	
	var fullBlinded: Player {
		return game.players.get(after: halfBlinded)!
	}
	
	var winner: Player? {
		if game.players.count - folded.count >= 2 {
			return nil
		}
		return game.players.get(after: dealer, excluding: folded)
	}
	
	var excluded: Set<Player> {
		var excluded = folded
		allIns.forEach() { allIn in
			excluded.insert(allIn.key)
		}
		return excluded
	}
	
	// MARK: Methods
	
	func play() -> Player {
		var bets: [Player: Int] = [Player(name: "Blind"): blinds.big]
		for (player, bet) in [halfBlinded: blinds.small, fullBlinded: blinds.big] {
			switch player.bet(amount: bet) {
			case .error(_, let stack) where stack == 0:
				Print.message("\(player.name) - Phantom blind")
			case .error(let message, let stack):
				Print.message("\(message) for \(player.name), going all-in")
				bets[player] = stack
				player.stack = 0
				checkAllIn(for: player)
			case .success:
				bets[player] = bet
			}
		}
		// Remove players eliminated during previous round
		for (index, player) in game.players.enumerated() where player.stack == 0 && bets[player] == nil {
			game.players.remove(at: index)
		}
		guard let active = game.players.get(after: fullBlinded) else {
			Print.error("Unable to get active player")
			// TODO: Controllare logica in caso di fallimento
			return dealer
		}
		var phase: GamePhase? = GamePhase.init(round: self, type: .preflop, pot: 0, bets: bets, active: active, ruler: active)
		repeat {
			// Play phases until river returns nil or a winning condition arises
			phase = phase?.play()
		} while phase != nil
		guard let nextDealer = game.players.get(after: dealer) else {
			Print.error("Unable to get next dealer")
			return dealer
		}
		return nextDealer
	}
	
	func checkAllIn(for player: Player) -> Void {
		if player.stack == 0 {
			allIns[player] = .toBeSet
			Print.log("\(player) added to all-ins")
		}
	}
	
}

enum AllInState: Equatable {
	case toBeSet, setted(amount: Int)
	static func ==(lhs: AllInState, rhs: AllInState) -> Bool {
		switch (lhs, rhs) {
		case (.setted, .setted):
			return true
		case (.toBeSet, .toBeSet):
			return true
		default:
			return false
		}
	}
}
