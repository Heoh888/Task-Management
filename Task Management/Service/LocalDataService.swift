//
//  LocalDataService.swift
//  Task Management
//
//  Created by Алексей Ходаков on 19.07.2023.
//

import SwiftData
import SwiftUI
import Observation
import Combine

@Observable
class LocalDataService {
    var modelContext: ModelContext? = nil
    var tasks = PassthroughSubject<[Task], Error>()
    var createTask = PassthroughSubject<Task, Error>()
    var deleteTask = PassthroughSubject<Task, Error>()
    
    func fetchTasks() {
        let descriptor = FetchDescriptor<Task>()
        guard let tasks = try? modelContext!.fetch(descriptor) else { return }
        self.tasks.send(tasks)
    }
    
    func createTask(taskTitle: String, creationDate: Date, tint: String) {
        let task = Task(taskTitle: taskTitle, creationDate: creationDate, tint: tint)
        modelContext?.insert(task)
        try? modelContext?.save()
        createTask.send(task)
        fetchTasks()
    }
    
    func deleteTask(task: Task) {
        modelContext?.delete(object: task)
        fetchTasks()
        deleteTask.send(task)
    }
    
    func deleteTask(task: TaskNetwork) {
        let resultPredicate2 = NSPredicate(format: "id = %@", task.id!)
        guard (try? modelContext?.delete(model: Task.self, where: resultPredicate2)) != nil else { return }
        fetchTasks()
    }
}
