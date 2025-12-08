import SwiftUI
import CoreData

struct TeacherRegisterView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    @State private var selectedCity = ""
    @State private var selectedRegion = ""
    @State private var selectedSchool = ""

    @State private var regions: [String] = []
    @State private var schools: [String] = []

    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Мұғалім тіркелу")
                    .font(.title2).bold()

                // Name
                TextField("Аты-жөні", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                // Email
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                // Password
                SecureField("Құпия сөз", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                // City picker
                Picker("Қала", selection: $selectedCity) {
                    ForEach(loadCities(), id: \.self) { city in
                        Text(city)
                    }
                }
                .onChange(of: selectedCity) {
                    // Load regions
                    regions = loadRegions(for: selectedCity)
                    selectedRegion = ""
                    selectedSchool = ""
                }

                // Region picker
                if !regions.isEmpty {
                    Picker("Аймақ", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region)
                        }
                    }
                    .onChange(of: selectedRegion) {
                        schools = loadSchools(for: selectedCity, region: selectedRegion)
                        selectedSchool = ""
                    }
                }

                // Schools picker
                if !schools.isEmpty {
                    Picker("Мектеп", selection: $selectedSchool) {
                        ForEach(schools, id: \.self) { schoolID in
                            Text(schoolName(for: schoolID))
                        }
                    }
                }

                // REGISTER BUTTON
                Button("Тіркелу") {
                    registerTeacher()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if showSuccess {
                    Text("Мұғалім сәтті тіркелді!")
                        .foregroundColor(.green)
                }

                if showError {
                    Text("Барлық өрісті толық толтырыңыз!")
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - SAVE TEACHER
    func registerTeacher() {
        guard !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !selectedSchool.isEmpty else {
            showError = true
            return
        }

        let teacher = Teacher(context: viewContext)
        teacher.id = UUID()
        teacher.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        teacher.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // for now store raw (for testing): later replace with hashed string
        teacher.passwordHash = password.trimmingCharacters(in: .whitespacesAndNewlines)
        teacher.city = selectedCity
        teacher.region = selectedRegion
        teacher.schoolID = selectedSchool
        


        do {
            try viewContext.save()
            showSuccess = true
        } catch {
            print("Error saving teacher: \(error)")
            showError = true
        }
    }
}
