//
//  main.swift
//  BetManager
//
//  Created by Alessandro Vanni on 18/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

print("* BET MANAGER *")

Print.colorized = Input.boolean(prompt: "Use colors?")

var game = Game()

Print.title("ADD PLAYERS")
while !game.ready {
	for name in Input.strings(prompt: "Player name") {
		switch game.add(player: name) {
		case .success(let message):
			Print.message(message)
		case .error(let message):
			Print.error(message)
		}
	}
	if !game.ready {
		Print.error("Not enough players to start the game, add more")
	}
}

// clear screen
// print("\u{001B}[2J")

Print.title("SET PLAYERS STACK")
game.players.set(stack: Input.integer(prompt: "Stack"))

Print.title("SEATS")
if Input.boolean(prompt: "Randomize?") {
	game.players.shuffle()
}

var dealer = game.players.randomElement()!
repeat {
	Print.title("Starting a new round")
	let round = Round(game: game, dealer: dealer, blinds: (big: 20, small: 10))
	dealer = round.play()
} while !game.hasWinner

Print.title("Congrants \(game.winner!.name), you are the winner!")


