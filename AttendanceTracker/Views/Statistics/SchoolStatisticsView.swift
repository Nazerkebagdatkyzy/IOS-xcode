//
//  SchoolStatisticsView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct SchoolStatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var school: School
    
    @State private var classStats: [(classRoom: ClassRoom, percent: Double)] = []
    @State private var teacherStats: [(teacher: Teacher, percent: Double)] = []
    @State private var schoolPercent: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // -------- Мектеп аты --------
                Text(school.name ?? "Мектеп")
                
                    .font(.largeTitle)
                    .bold()
                
                // -------- Жалпы мектеп пайызы --------
                VStack(alignment: .leading, spacing: 10) {
                    Text("Жалпы қатысу пайызы")
                        .font(.headline)
                    
                    Text(String(format: "%.1f%%", schoolPercent))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // -------- Сыныптар рейтингі --------
                VStack(alignment: .leading, spacing: 10) {
                    Text("Сыныптар бойынша рейтинг")
                        .font(.headline)
                    
                    ForEach(classStats, id: \.classRoom.objectID) { item in
                        HStack {
                            Text(item.classRoom.name ?? "Сынып")
                            Spacer()
                            Text(String(format: "%.1f%%", item.percent))
                                .bold()
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    
                    if classStats.isEmpty {
                        Text("Статистика жоқ")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // -------- Мұғалімдер статистикасы --------
                VStack(alignment: .leading, spacing: 10) {
                    Text("Мұғалімдердің орташа статистикасы")
                        .font(.headline)
                    
                    ForEach(teacherStats, id: \.teacher.objectID) { item in
                        HStack {
                            Text(item.teacher.name ?? "Мұғалім")
                            Spacer()
                            Text(String(format: "%.1f%%", item.percent))
                                .bold()
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    
                    if teacherStats.isEmpty {
                        Text("Мұғалімдер жоқ немесе статистика бос")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Мектеп статистикасы")
        .onAppear(perform: computeSchoolStats)
    }
    
    
    // =====================================================
    //               МЕКТЕП СТАТИСТИКА ЕСЕПТЕУ
    // =====================================================
    private func computeSchoolStats() {
        print("SCHOOL:", school.name ?? "??")
        print("CLASSES COUNT:", (school.classes as? Set<ClassRoom>)?.count ?? 0)
        
        for classRoom in (school.classes as? Set<ClassRoom>) ?? [] {
            print("CLASS:", classRoom.name ?? "??")
            print("STUDENTS:", (classRoom.students as? Set<Student>)?.count ?? 0)
            
            
            // 1) Мектептегі барлық сыныптар
            let classes = (school.classes as? Set<ClassRoom>) ?? []
            
            var totalPresent = 0
            var totalPossible = 0
            
            var perClass: [(ClassRoom, Double)] = []
            var perTeacherDict: [Teacher: [Double]] = [:]
            
            for classRoom in classes {
                
                // ----- класс ішіндегі оқушылар -----
                let students = (classRoom.students as? Set<Student>) ?? []
                if students.isEmpty { continue }
                
                // ----- Attendance жинау -----
                let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
                req.predicate = NSPredicate(format: "student.classRoom == %@", classRoom)
                
                do {
                    let records = try viewContext.fetch(req)
                    
                    // ----- күндер -----
                    let days = Set(records.compactMap { Calendar.current.startOfDay(for: $0.date ?? Date()) })
                    let totalDays = days.count
                    
                    if totalDays == 0 { continue }
                    
                    // ----- оқушы бойынша есеп -----
                    let classTotalPossible = totalDays * students.count
                    let classPresent = records.filter { $0.status == "present" }.count
                    
                    let classPercent = Double(classPresent) / Double(classTotalPossible) * 100
                    perClass.append((classRoom, classPercent))
                    
                    totalPresent += classPresent
                    totalPossible += classTotalPossible
                    
                    // ----- Мұғалімге қосу -----
                    if let t = classRoom.teacher {
                        perTeacherDict[t, default: []].append(classPercent)
                    }
                    
                } catch {
                    print("Fetch error:", error)
                }
            }
            
            // ---- Сыныптар сорттау ----
            classStats = perClass.sorted { $0.1 > $1.1 }
            
            // ---- Мектеп жалпы пайыз ----
            schoolPercent = totalPossible > 0 ? (Double(totalPresent) / Double(totalPossible)) * 100 : 0
            
            // ---- Мұғалімдер статистикасы ----
            teacherStats = perTeacherDict.map { (teacher, values) in
                let avg = values.reduce(0, +) / Double(values.count)
                return (teacher, avg)
            }
            .sorted { $0.1 > $1.1 }
        }
    }
}
