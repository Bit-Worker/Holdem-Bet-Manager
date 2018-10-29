//
//  Input.swift
//  BetManager
//
//  Created by Alessandro Vanni on 20/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

enum Input {
	
	static let end: [String] = ["done", "exit", "end"]
	static let yes: [String] = ["y", "yes"]
	static let no: [String] = ["n", "no"]
	static let commands: [String] = ["call", "raise X", "fold", "allin", "check", "summary"]
	
	static func string(prompt: String? = .none) -> String {
		if let prompt = prompt {
			Print.input(prompt)
		}
		guard let input = readLine(), !input.isEmpty else {
			Print.error("Bad input")
			return string(prompt: prompt)
		}
		return input
	}
	
	static func strings (
		prompt: String? = .none,
		end commands: [String] = end,
		showHelp: Bool = true) -> [String] {
		if showHelp {
			Print.info("Type \(commands.printed) to exit")
		}
		if let prompt = prompt {
			Print.input(prompt)
		}
		guard let input = readLine(), !input.isEmpty else {
			Print.error("Bad input")
			return strings(prompt: prompt, end: commands, showHelp: false)
		}
		return commands.contains(input.lowercased()) ? [] : [input] + strings(prompt: prompt, end: commands, showHelp: false)
	}
	
	static func integer(prompt: String? = .none) -> Int {
		if let prompt = prompt { Print.input(prompt) }
		guard let input = Int(readLine() ?? "") else {
			Print.error("Bad input")
			return integer(prompt: prompt)
		}
		return input
	}
	
	static func boolean (prompt: String? = .none, yes: [String] = yes, no: [String] = no, showHelp: Bool = true) -> Bool {
		if showHelp {
			Print.info("Type \(yes.printed) for YES, \(no.printed) for NO")
		}
		if let prompt = prompt {
			Print.input(prompt)
		}
		if let input = readLine()?.lowercased(), !input.isEmpty {
			if yes.contains(input) {
				return true
			}
			else if no.contains(input) {
				return false
			}
		}
		Print.error("Bad input")
		return boolean(prompt: prompt, yes: yes, no: no, showHelp: false)
	}
	
	static func command(prompt: String? = nil, commands: [String] = commands, showHelp: Bool = true) -> Command {
		if showHelp {
			Print.info("Type \(commands.printed)")
		}
		if let prompt = prompt {
			Print.input(prompt)
		}
		var input = Input.string().lowercased().split(separator: " ")
		guard let action = Command.init(from: String(input.removeFirst())) else {
			Print.error("Bad command")
			return command(prompt: prompt, commands: commands, showHelp: false)
		}
		switch action {
		case .raise(amount: _):
			guard !input.isEmpty, let amount = Int(input.first!) else {
				return .raise(amount: Input.integer(prompt: "Insert amount"))
			}
			return .raise(amount: amount)
		// TODO: Add system command arguments
		default:
			return action
		}
	}
	
	enum Command {
		case call, raise(amount: Int), fold, allin, check, summary, system
		init?(from value: String) {
			switch value {
			case "call":
				self = .call
			case "raise":
				self = .raise(amount: 0)
			case "fold":
				self = .fold
			case "allin":
				self = .allin
			case "check":
				self = .check
			case "summary":
				self = .summary
			case "system":
				self = .system
			default:
				return nil
			}
		}
	}
	
}








