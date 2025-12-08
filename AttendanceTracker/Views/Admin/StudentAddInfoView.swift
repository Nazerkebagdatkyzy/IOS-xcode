//
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
// StudentAddInfoView.swift
import SwiftUI
import CoreData

struct StudentAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let classRoom: ClassRoom
    
    @State private var name = ""
    @State private var number = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Оқушы аты-жөні")
                        .font(.headline)
                    TextField("Мысалы: Айдос Қанатұлы", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Оқушы нөмірі")
                        .font(.headline)
                    TextField("Мысалы: 5", text: $number)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .keyboardType(.numberPad)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Button(action: saveStudent) {
                    Text("Сақтау")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Оқушы қосу")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Жабу") { dismiss() }
                }
            }
        }
    }
    
    private func saveStudent() {
        guard !name.isEmpty else {
            errorMessage = "Аты-жөні бос болмауы керек"
            return
        }
        
        guard let num = Int16(number) else {
            errorMessage = "Нөмір тек сан болуы керек"
            return
        }
        
        let s = Student(context: viewContext)
        s.id = UUID()
        s.name = name
        s.studentNumber = num
        s.classRoom = classRoom
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Сақтау кезінде қате пайда болды"
        }
    }
}
