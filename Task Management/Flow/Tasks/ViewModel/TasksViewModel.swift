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
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { tasks in
                self.tasks = []
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: self.currentDate)
                let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
                let predicate = #Predicate<Task> {
                    return $0.creationDate >= startDate && $0.creationDate < endDate
                }
                self.tasks = try! tasks.filter(predicate)
            }
            .store(in: &cancellables)
        
        localDataService.createTask
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { task in
                let data: [String: Any] = [
                    "id": task.id,
                    "taskTitle": task.taskTitle,
                    "isComplited": task.isComplited,
                    "tint": task.tint,
                    "creationDate": task.creationDate
                ]
                networkService.setData(id: task.id, data: data)
            }
            .store(in: &cancellables)
        
        localDataService.deleteTask
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { task in
                networkService.deleteData(id: task.id)
            }
            .store(in: &cancellables)
        
        networkService.newTasks
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { newTask in
                print(newTask)
            }
            .store(in: &cancellables)
        
        networkService.modifiedTask
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { newTask in
                self.tasks.forEach { task in
                    if task.id == newTask.id {
                        if let index = self.tasks.firstIndex(where: {$0 === task}) {
                            self.tasks[index].isComplited = newTask.isComplited
                            self.tasks[index].tint = newTask.tint
                            self.tasks[index].taskTitle = newTask.taskTitle
                            self.tasks[index].creationDate = newTask.creationDate
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        networkService.deleteTask
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            } receiveValue: { remoteTask in
                self.localDataService.deleteTask(task: remoteTask)
            }
            .store(in: &cancellables)
    }
    
    func fetchTask() {
        localDataService.fetchTasks()
    }
    
    func createTask(taskTitle: String, creationDate: Date, tint: String) {
        localDataService.createTask(taskTitle: taskTitle, creationDate: creationDate, tint: tint)
    }
    
    func updateTask(task: Task) {
        networkService.updateData(id: task.id, data: ["isComplited": task.isComplited])
    }
    
    func deleteTask(task: Task) {
        localDataService.deleteTask(task: task)
    }
}
