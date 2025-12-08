//
//  AdminRegisterView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminRegisterView: View {
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
                Text("Админ тіркелу")
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

                // School picker
                if !schools.isEmpty {
                    Picker("Мектеп", selection: $selectedSchool) {
                        ForEach(schools, id: \.self) { school in
                            Text(school)
                        }
                    }
                }

                // REGISTER BUTTON
                Button("Тіркелу") {
                    registerAdmin()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if showSuccess {
                    Text("Админ сәтті тіркелді!")
                        .foregroundColor(.green)
                }

                if showError {
                    Text("Барлық өрісті толтырыңыз!")
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - SAVE ADMIN
    func registerAdmin() {
        guard !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !selectedSchool.isEmpty else {
            showError = true
            return
        }

        let newAdmin = SchoolAdmin(context: viewContext)
        newAdmin.id = UUID()
        newAdmin.name = name
        newAdmin.email = email
        newAdmin.passwordHash = password
        newAdmin.schoolID = selectedSchool

        do {
            try viewContext.save()
            showSuccess = true
        } catch {
            print("Error saving admin: \(error)")
            showError = true
        }
    }
}

