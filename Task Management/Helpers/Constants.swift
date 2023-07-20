//
//  Constants.swift
//  Task Management
//
//  Created by Алексей Ходаков on 18.07.2023.
//

import FirebaseFirestore

struct Constants {
    struct FireBase {
        static let collectionTasks = Firestore.firestore().collection("tasks")
    }
}
