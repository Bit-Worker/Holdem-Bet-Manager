//
//  Print.swift
//  BetManager
//
//  Created by Alessandro Vanni on 29/09/2018.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

enum Print {
	
	static var colorized = false
	
	static func input(_ text: String) {
		let prompt = colorized ? Color.green.rawValue : ""
		let input = colorized ? Color.purple.rawValue : ""
		print("\(prompt)\(text): \(input)", separator: "", terminator: "")
	}
	
	static func title(_ title: String) {
		let color = colorized ? Color.yellow.rawValue : ""
		print("\(color)\n\(title)")
	}
	
	static func message(_ message: String) {
		let color = colorized ? Color.cyan.rawValue : ""
		print("\(color)   MESSAGE: \(message)")
	}
	
	static func error(_ error: String) {
		let color = colorized ? Color.red.rawValue : ""
		print("\(color)   ERROR: \(error)")
	}
	
	static func info(_ info: String) {
		let color = colorized ? Color.brigthBlack.rawValue : ""
		print("\(color)\(info)")
	}
	
	static func log(_ log: String) {
		let color = colorized ? Color.brigthBlack.rawValue : ""
		print("\(color)   -> \(log)")
	}
	
}

