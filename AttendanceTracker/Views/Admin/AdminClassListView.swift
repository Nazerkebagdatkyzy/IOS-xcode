//
//  AdminClassListView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminClassListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClassRoom.name, ascending: true)]
    ) private var classes: FetchedResults<ClassRoom>

    @State private var showAddClass = false

    var body: some View {
        NavigationView {
            List {
                ForEach(classes) { classRoom in
                    NavigationLink(destination: AdminClassDetailView(classRoom: classRoom)) {
                        VStack(alignment: .leading) {
                            Text(classRoom.name ?? "Аты жоқ")
                                .font(.headline)

                            Text("Оқушылар саны: \(classRoom.students?.count ?? 0)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Сыныптар")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddClass = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddClass) {
                AdminAddClassView()
            }
        }
    }
}
