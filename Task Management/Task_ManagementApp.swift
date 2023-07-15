//
//  Task_ManagementApp.swift
//  Task Management
//
//  Created by Алексей Ходаков on 15.07.2023.
//

import SwiftUI
import SwiftData

@main
struct Task_ManagementApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
