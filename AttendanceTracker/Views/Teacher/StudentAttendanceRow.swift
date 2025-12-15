
import SwiftUI
import CoreData

struct StudentAttendanceRow: View {

    let student: Student

    @Binding var isPresent: Bool
    @Binding var tardyMinutes: Int
    @Binding var tardyReason: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // HEADER
            HStack {
                VStack(alignment: .leading) {
                    Text(student.name ?? "Аты жоқ")
                    Text("№\(student.studentNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $isPresent)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }

            // TARDY
            if isPresent {

                HStack {
                    Text("Кешігу (мин):")
                        .font(.caption)

                    Stepper(value: $tardyMinutes, in: 0...60) {
                        Text("\(tardyMinutes)")
                    }
                }

                if tardyMinutes > 0 {
                    TextField("Кешігу себебі", text: $tardyReason)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            NavigationLink(
                destination: StudentHistoryView(student: student)
            ) {
                Text("Ақпарат")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(10)
            }


            Divider()
        }
        .padding(.vertical, 4)
    }
}
