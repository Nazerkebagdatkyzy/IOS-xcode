//
//  AttendanceHistoryRow .swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 17.12.2025.
//
import SwiftUI

struct AttendanceHistoryRow: View {

    let attendance: Attendance

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(attendance.date ?? Date(), style: .date)
                    .font(.headline)

                Spacer()

                statusLabel
            }

            if attendance.tardyMinutes > 0 {
                Text("⏰ Кешікті: \(attendance.tardyMinutes) мин")
                    .font(.subheadline)

                if let reason = attendance.tardyReason, !reason.isEmpty {
                    Text("Себебі: \(reason)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }

    private var statusLabel: some View {
        Group {
            if !attendance.isPresent {
                Text("❌ Келмеді")
                    .foregroundColor(.red)
            } else if attendance.tardyMinutes > 0 {
                Text("⏰ Кешікті")
                    .foregroundColor(.orange)
            } else {
                Text("✅ Келді")
                    .foregroundColor(.green)
            }
        }
        .font(.subheadline)
        .bold()
    }
}

