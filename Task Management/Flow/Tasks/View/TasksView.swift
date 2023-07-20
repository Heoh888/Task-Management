//
//  TasksView.swift
//  Task Management
//
//  Created by Алексей Ходаков on 18.07.2023.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var context
    @Binding var currentDate: Date
    @State var viewModel: TasksViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task, viewModel: viewModel)
                    .background(alignment: .leading) {
                        if viewModel.tasks.last?.id != task.id {
                            Rectangle()
                                .frame(width: 1)
                                .offset(x: 8)
                                .padding(.bottom, -35)
                        }
                    }
            }
        }
        .padding([.vertical, .leading], 15)
        .padding(.top, 15)
        .overlay {
            if viewModel.tasks.isEmpty {
                Text("No Task`s Found")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(width: 150)
            }
        }
        .onChange(of: currentDate, { oldValue, newValue in
            if currentDate != oldValue {
                viewModel.currentDate = newValue
                viewModel.fetchTask()
            }
        })
        .onAppear {
            viewModel.localDataService.modelContext = context
            viewModel.currentDate = currentDate
            viewModel.fetchTask()
        }
    }
}

