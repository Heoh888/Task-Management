//
//  Task.swift
//  Task Management
//
//  Created by Алексей Ходаков on 15.07.2023.
//
import FirebaseFirestoreSwift
import SwiftData
import SwiftUI

@Model
class Task: Identifiable {
    var id: String
    var taskTitle: String
    var creationDate: Date
    var isComplited: Bool
    var tint: String
    
    init(id: String = UUID().uuidString, taskTitle: String, creationDate: Date = .init(), isComplited: Bool = false, tint: String) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isComplited = isComplited
        self.tint = tint
    }
    
    var tintColor: Color {
        switch tint {
        case "taskColor 1": return .taskColor1
        case "taskColor 2": return .taskColor2
        case "taskColor 3": return .taskColor3
        case "taskColor 4": return .taskColor4
        case "taskColor 5": return .taskColor5
        default: return .black
        }
    }
}

struct TaskNetwork: Identifiable, Decodable {
    @DocumentID var id: String?
    var taskTitle: String
    var creationDate: Date
    var isComplited: Bool
    var tint: String
}
