//
//  TasksViewModel.swift
//  Task Management
//
//  Created by Алексей Ходаков on 18.07.2023.
//

import SwiftData
import SwiftUI
import Observation
import Combine

@Observable
class TasksViewModel {
    
    var currentDate: Date = .init()
    var tasks: [Task] = []
    var localDataService = LocalDataService()
    
    private let networkService: NetworkServiceProtocol!
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        
        networkService.listensToCollection()
        
        localDataService.tasks
            .sink { self.displayTasks(tasks: $0) }
            .store(in: &cancellables)
        
        localDataService.createTask
            .sink { self.saveTaskOnServer(task: $0) }
            .store(in: &cancellables)
        
        localDataService.deleteTask
            .receive(on: RunLoop.main)
            .sink { networkService.deleteData(taskId: $0.id) }
            .store(in: &cancellables)
        
        networkService.addedTasks
            .sink { self.addedTasks(task: $0) }
            .store(in: &cancellables)
        
        networkService.modifiedTask
            .sink { self.modifiedTask(tasks: $0) }
            .store(in: &cancellables)
        
        networkService.deleteTask
            .sink{ self.localDataService.deleteTask(task: $0) }
            .store(in: &cancellables)
    }
    
    func fetchTask() {
        localDataService.fetchTasks()
    }
    
    func createTask(taskTitle: String, creationDate: Date, tint: String) {
        localDataService.createTask(taskTitle: taskTitle, creationDate: creationDate, tint: tint)
    }
    
    func updateTask(task: Task) {
        networkService.updateData(taskId: task.id, data: ["isComplited": task.isComplited])
    }
    
    func deleteTask(task: Task) {
        localDataService.deleteTask(task: task)
    }
    
    private func modifiedTask(tasks: TaskNetwork) {
        self.tasks.forEach { task in
            if task.id == tasks.id {
                if let index = self.tasks.firstIndex(where: {$0 === task}) {
                    self.tasks[index].isComplited = tasks.isComplited
                    self.tasks[index].tint = tasks.tint
                    self.tasks[index].taskTitle = tasks.taskTitle
                    self.tasks[index].creationDate = tasks.creationDate
                }
            }
        }
    }
    
    private func saveTaskOnServer(task: Task) {
        let data: [String: Any] = [
            "taskTitle": task.taskTitle,
            "isComplited": task.isComplited,
            "tint": task.tint,
            "creationDate": task.creationDate
        ]
        networkService.setData(taskId: task.id, data: data)
    }
    
    private func displayTasks(tasks: [Task]) {
        self.tasks = []
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: self.currentDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = #Predicate<Task> {
            $0.creationDate >= startDate && $0.creationDate < endDate
        }
        self.tasks = try! tasks.filter(predicate)
    }
    
    private func addedTasks(task: TaskNetwork) {
        if self.tasks.firstIndex(where: { $0.id == task.id }) == nil {
            let task = Task(id: task.id!,
                            taskTitle: task.taskTitle,
                            creationDate: task.creationDate,
                            isComplited: task.isComplited,
                            tint: task.tint)
            localDataService.addedTasks(task: task)
        }
    }
}
