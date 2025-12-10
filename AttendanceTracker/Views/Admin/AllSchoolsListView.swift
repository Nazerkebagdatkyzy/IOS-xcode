//
//  AllSchoolsListView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//

import SwiftUI
import CoreData

struct AllSchoolsListView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \School.name, ascending: true)]
    ) private var schools: FetchedResults<School>
    
    var body: some View {
        List {
            ForEach(schools) { school in
                NavigationLink(destination: SchoolStatisticsView(school: school)) {
                    VStack(alignment: .leading) {
                        Text(school.name ?? "Атауы жоқ")
                            .font(.headline)
                        Text("\(school.city ?? "") • \(school.region ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Барлық мектептер")
    }
}
