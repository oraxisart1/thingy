//
//  Item.swift
//  Thingy
//
//  Created by Artem Borodikhin on 12/4/26.
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
