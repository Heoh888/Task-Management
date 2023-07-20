//
//  NetworkService.swift
//  Task Management
//
//  Created by Алексей Ходаков on 18.07.2023.
//

import FirebaseFirestore
import FirebaseDatabase
import FirebaseFirestoreCombineSwift
import Combine

protocol NetworkServiceProtocol {
    var addedTasks: PassthroughSubject<TaskNetwork, Never> { get set }
    var modifiedTask: PassthroughSubject<TaskNetwork, Never> { get set }
    var deleteTask: PassthroughSubject<TaskNetwork, Never> { get set }
    func setData(taskId: String, data: [String: Any])
    func updateData(taskId: String, data: [String : Any])
    func listensToCollection()
    func deleteData(taskId: String)
}

class NetworkService: NetworkServiceProtocol {
    
    var addedTasks = PassthroughSubject<TaskNetwork, Never>()
    var modifiedTask = PassthroughSubject<TaskNetwork, Never>()
    var deleteTask = PassthroughSubject<TaskNetwork, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func setData(taskId: String, data: [String: Any]) {
        Constants.FireBase.collectionTasks.document(taskId).setData(data) { error in
            guard let error = error else { return }
            print("❗️\(#function): \(error.localizedDescription)")
        }
    }
    
    func updateData(taskId: String, data: [String : Any]) {
        Constants.FireBase.collectionTasks.document(taskId).updateData(data) { error in
            guard let error = error else { return }
            print("❗️\(#function): \(error.localizedDescription)")
        }
    }
    
    func listensToCollection() {
        Constants.FireBase.collectionTasks.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { diff in
                switch diff.type {
                case .added:
                    guard let task = try? diff.document.data(as: TaskNetwork.self) else { return }
                    self.addedTasks.send(task)
                case .modified:
                    guard let task = try? diff.document.data(as: TaskNetwork.self) else { return }
                    self.modifiedTask.send(task)
                case .removed:
                    guard let task = try? diff.document.data(as: TaskNetwork.self) else { return }
                    self.deleteTask.send(task)
                }
            }
        }
    }
    
    func deleteData(taskId: String) {
        Constants.FireBase.collectionTasks.document(taskId).delete() { error in
            guard let error = error else { return }
            print("❗️\(#function): \(error.localizedDescription)")
        }
    }
}
