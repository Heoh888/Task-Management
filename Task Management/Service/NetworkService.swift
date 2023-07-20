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
    var newTasks: PassthroughSubject<TaskNetwork, Error> { get set }
    var modifiedTask: PassthroughSubject<TaskNetwork, Error> { get set }
    var deleteTask: PassthroughSubject<TaskNetwork, Error> { get set }
    func setData(id: String, data: [String: Any])
    func updateData(id: String, data: [String : Any])
    func getData() -> Future<[TaskNetwork], Error>
    func listensToCollection()
    func deleteData(id: String)
}

class NetworkService: NetworkServiceProtocol {
    
    var newTasks = PassthroughSubject<TaskNetwork, Error>()
    var modifiedTask = PassthroughSubject<TaskNetwork, Error>()
    var deleteTask = PassthroughSubject<TaskNetwork, Error>()
    private var cancellables = Set<AnyCancellable>()
    
    func setData(id: String, data: [String: Any]) {
        Constants.FireBase.collectionTasks.document(id).setData(data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func updateData(id: String, data: [String : Any]) {
        Constants.FireBase.collectionTasks.document(id).updateData(data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func getData() -> Future<[TaskNetwork], Error> {
        return Future({ promise in
            Constants.FireBase.collectionTasks.getDocuments { querySnapshot, error in
                var data: [TaskNetwork] = []
                if let error = error {
                    promise(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        guard let task = try? document.data(as: TaskNetwork.self) else { return }
                        data.append(task)
                    }
                }
                promise(.success(data))
            }
        })
    }
    
    func listensToCollection() {
        Constants.FireBase.collectionTasks.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { diff in
                switch diff.type {
                case .added:
                    guard let task = try? diff.document.data(as: TaskNetwork.self) else { return }
                    self.newTasks.send(task)
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
    
    func deleteData(id: String) {
        Constants.FireBase.collectionTasks.document(id).delete()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: print("🏁 finished")
                case .failure(let error): print("❗️ failure: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
