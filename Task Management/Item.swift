//
//  Item.swift
//  Task Management
//
//  Created by Алексей Ходаков on 15.07.2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
