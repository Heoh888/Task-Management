//
//  ContentView.swift
//  Task Management
//
//  Created by Алексей Ходаков on 15.07.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        Home()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.BG)
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
