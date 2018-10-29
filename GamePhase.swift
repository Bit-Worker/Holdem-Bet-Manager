//
//  Phase.swift
//  BetManager
//
//  Created by Alessandro Vanni on 20/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

import Foundation

struct GamePhase {
	
	// MARK: Properties
	
	var round: Round
	let type: PhaseType
	let pot: Int
	
	var bets: [Player: Int] = [:] {
		didSet {
			Print.log("Bets: \(bets)")
		}
	}
	
	var active: Player {
		didSet {
			Print.log("Active player is \(active.name)")
		}
	}
	
	var ruler: Player {
		didSet {
			Print.log("Last player is \(ruler.name)")
		}
	}
	
	var players: [Player] {
		return round.game.players
	}
	
	var dealer: Player {
		return round.dealer
	}
	
	var allIns: [Player: AllInState] {
		get {
			return round.allIns
		}
		set(players) {
			round.allIns.merge(players) {
				(_, new) in new
			}
		}
	}
	
	var folded: Set<Player> {
		get {
			return round.folded
		}
		set (players) {
			round.folded = round.folded.union(players)
		}
	}
	
	var excluded: Set<Player> {
		return round.excluded
	}
	
	// MARK: Methods
	
	mutating func play() -> GamePhase? {
		Print.title("Entering \(type)")
		switch type {
		case .flop:
			Print.message("Deal 3 cards")
		case .river, .turn:
			Print.message("Deal 1 card")
		default:
			break
		}
		var done: Bool
		repeat {
			done = true
			let next = players.get(after: active, excluding: excluded)!
			Print.title("\(active.name) (stack: \(active.stack))")
			Print.info("Current bet: \(bets[active] ?? 0)")
			switch (active === next, bets[active] ?? 0 < bets.max, active.stack + (bets[active] ?? 0) > bets.max) {
			case (false, _, _):
				break
			case (true, false, _):
				setAllInsPot()
				InputWinners()
				return nil
			case (true, true, true):
				if Input.boolean(prompt: "Do you wanna call?") {
					Print.message("\(active.name) calls \(bets.max)")
					active.bet(amount: bets.max - (bets[active] ?? 0))
					bets[active] = bets.max
					setAllInsPot()
					InputWinners()
					return nil
				} else {
					if onePlayerRemains() {
						return nil
					}
					InputWinners()
					return nil
				}
			case (true, true, false):
				if Input.boolean(prompt: "Do you wanna go all-in?") {
					setAllIn()
					setAllInsPot()
					InputWinners()
					return nil
				} else {
					if onePlayerRemains() { return nil }
					InputWinners()
					return nil
				}
			}
			let command = Input.command(prompt: "Bet to match \(bets.max)")
			switch command {
			case .call:
				switch active.bet(amount: bets.max - (bets[active] ?? 0)) {
				case .success:
					Print.message("\(active.name) calls \(bets.max)")
					bets[active] = bets.max
					round.checkAllIn(for: active)
					active = next
				case .error(let message, let stack):
					Print.message("\(message), current stack for \(active.name) is \(stack)")
					done = false
				}
			case .raise(let amount):
				if active.stack <= bets.max - (bets[active] ?? 0) {
					Print.error("Not enough chips to raise")
					done = false
				} else if amount <= bets.max {
					Print.error("Raise is \(amount == bets.max ? "equal" : "under") maximum bet")
					done = false
				} else if amount <= bets[active] ?? 0 {
					Print.error("Raise is \(amount == (bets[active] ?? 0) ? "equal" : "under") your current bet")
					done = false
				} else {
					switch active.bet(amount: amount - (bets[active] ?? 0)) {
					case .success:
						Print.message("\(active.name) raises to \(amount)")
						bets[active] = amount
						ruler = active
						round.checkAllIn(for: active)
						active = next
					case .error(let message, let stack):
						Print.error("\(message), current maximum bet for \(active.name) is \(stack + (bets[active] ?? 0))")
						done = false
					}
				}
			case .fold:
				if onePlayerRemains() {
					return nil
				}
				active = next
			case .allin:
				let raising = active.stack > bets.max
				Print.message("\(active.name) \(raising ? "raises to \(active.stack)" : "calls going all-in")")
				if raising {
					ruler = active
				}
				setAllIn()
				active = next
			case .check:
				if (bets[active] ?? 0) == bets.max {
					active = next
				} else {
					Print.error("You have to fold or match \(bets.max) bet")
					done = false
				}
			case .summary:
				Print.info("Game players: \(players)")
				Print.info("Folded players: \(folded)")
				Print.info("All-in players: \(allIns)")
				Print.info("Pot: \(pot)")
				Print.info("Bets: \(bets)")
				done = false
			case .system:
				// TODO: System commands
				done = false
			}
		} while active != ruler || !done
		if !allIns.isEmpty {
			setAllInsPot()
		}
		guard let nextType = type.next() else {
			InputWinners()
			return nil
		}
		// TODO: Eliminare punto esclamativo
		let speaker = excluded.contains(dealer) ? players.get(after: dealer, excluding: excluded)! : dealer
		return GamePhase(round: round, type: nextType, pot: pot + bets.total, bets: [:], active: speaker, ruler: speaker)
	}
	
	private mutating func onePlayerRemains() -> Bool {
		Print.message("\(active.name) folds")
		folded.insert(active)
		if let winner = round.winner {
			Print.title("Round winner is \(winner.name)")
			winner.stack += pot + bets.total
			return true
		}
		return false
	}
	
	private mutating func setAllIn() {
		bets[active] = active.stack + (bets[active] ?? 0)
		active.stack = 0
		round.checkAllIn(for: active)
	}
	
	private mutating func setAllInsPot() {
		let bets = self.bets.filter() { bet in
			bet.key.name != "Blind"
		}
		for (player, state) in allIns where state == .toBeSet {
			let personalPot = bets.reduce(pot) { pot, bet in
				pot + min(bet.value, bets[player] ?? 0)
			}
			allIns[player] = .setted(amount: personalPot)
		}
	}
	
	private mutating func InputWinners() {
		var pot = self.pot + bets.total
		var excluded: Set<Player> = [] // Contains players who cannot partecipate to pot splitting
		repeat {
			Print.message("Payout \(pot)")
			var winners: [Player: PotLimit] = [:]
			repeat {
				Print.info("Type winners name (comma separated) if split pot")
				let input = Input.string(prompt: "Insert showdown winner(s) name").uppercased()
				let values = input.split(separator: ",")
				namesLoop: for value in values {
					let name = String(value).trimmingCharacters(in: .whitespaces)
					if let player = players.find(named: String(name)), !excluded.contains(player) {
						if let state = allIns[player] {
							switch state {
							case .setted(let amount):
								winners[player] = .limited(to: amount)
							default:
								Print.error("All-in value for \(player.name) not set")
								winners = [:]
								break namesLoop
							}
						} else {
							winners[player] = .unlimited
						}
					} else {
						Print.error("Bad name (\(name))")
						winners = [:]
						break
					}
				}
			} while winners.isEmpty
			// Remove all all-ins wich have a personal pot lower than greatest actual winner
			// as they cannot partecipate to the pot
			switch winners.maximumLimit {
			case .unlimited: // No other all-in is elegible to win
				for (player, _) in allIns where !excluded.contains(player) {
					excluded.insert(player)
				}
			case .limited(let limit):
				for (player, state) in allIns where !excluded.contains(player) {
					switch state {
					case .setted(let amount): // If all-in max amount is lower he isn't elegible for pot
						if amount <= limit {
							excluded.insert(player)
						}
					default:
						// All all-ins must have been setted at this stage
						Print.error("All-in not set for \(player.name)")
					}
				}
			}
			// Divide pot between players starting from minimum personal pot
			potSplittingLoop: repeat {
				switch winners.minimumLimit {
				case .unlimited:
					let prize = (value: pot / winners.count, remainder: pot % winners.count)
					for (player, _) in winners {
						player.stack += prize.value
						pot -= prize.value
					}
					// TODO: Add reporting chips to next round
					Print.message("Remainder for next round is \(prize.remainder)")
					break potSplittingLoop
				case .limited(let amount):
					// Adjust winning limits for other players
					for (player, state) in allIns {
						switch state {
						case .setted(let limit):
							allIns[player] = .setted(amount: limit - amount)
						default:
							// All all-ins must have been setted at this stage
							Print.error("All-in not set for \(player.name)")
						}
					}
					let prize = (value: amount / winners.count, remainder: amount % winners.count)
					for (player, potLimit) in winners {
						player.stack += prize.value
						pot -= prize.value
						switch potLimit {
						case .limited(let limit) where limit == amount:
							// Player has been fully paid, remove from winners
							winners[player] = nil
						case .limited(let limit) where limit > amount:
							winners[player] = .limited(to: limit - amount)
						default:
							break
						}
					}
					Print.message("Remainder for next round is \(prize.remainder)")
				}
			} while !winners.isEmpty
		} while pot > 0
	}
	
}
	
// MARK: Enumerations
	
enum PhaseType: Int, CustomStringConvertible {
	case preflop = 1, flop, turn, river
	func next() -> PhaseType? {
		Print.log("Leaving \(self)")
		return self != .river ? PhaseType(rawValue: self.rawValue + 1) : nil
	}
	var description: String {
		switch self {
		case .preflop:
			return "PRE-FLOP"
		case .flop:
			return "FLOP"
		case .turn:
			return "TURN"
		case .river:
			return "RIVER"
		}
	}
}

enum PotLimit {
	case limited(to: Int), unlimited
}

