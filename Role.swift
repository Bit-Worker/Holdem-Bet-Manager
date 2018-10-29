//
//  Role.swift
//  BetManager
//
//  Created by Alessandro Vanni on 19/09/18.
//  Copyright © 2018 Alessandro Vanni. All rights reserved.
//

struct RoleIndex {
	var index: Int
	func next(in collection: [Player]) -> RoleIndex {
		if index + 1 >= collection.count { return RoleIndex(index: 0) }
		else { return RoleIndex(index: self.index + 1) }
	}
}

extension Array where Element == Player {
	
	var areClashing: Bool { return self.count > 1 }
	
	func randomPlayer() -> RoleIndex? {
		return self.isEmpty ? .none : RoleIndex(index: Int.random(in: 0..<self.count))
	}
	
	func player(after role: RoleIndex) -> RoleIndex {
		if role.index + 1 >= self.count { return RoleIndex(index: 0) }
		else { return RoleIndex(index: role.index + 1) }
	}
	
}
