//
//  HomeView.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 28.11.2025.
//
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Group.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Group.name, ascending: true)])
    private var groups: FetchedResults<Group>

    @State private var showingAddGroup = false

    var body: some View {
        NavigationView {
            List {
                ForEach(groups) { group in
                    NavigationLink(destination: StudentListView(group: group)) {
                        HStack {
                            Text(group.name ?? "Топ")
                            Spacer()
                            Text("\(group.studentsArray.count) студент")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteGroups)
            }
            .navigationTitle("Топтар")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGroup = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView()
                    .environment(\.managedObjectContext, viewContext)
            }
            Text("Топты таңдаңыз")
                .foregroundColor(.secondary)
        }
    }

    private func deleteGroups(offsets: IndexSet) {
        withAnimation {
            offsets.map { groups[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Save error: \(error)")
        }
    }
}

