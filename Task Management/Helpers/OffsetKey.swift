//
//  OffsetKey.swift
//  Task Management
//
//  Created by Алексей Ходаков on 16.07.2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
