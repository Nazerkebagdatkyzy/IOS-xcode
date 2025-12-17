//
//  EmeraldComponents.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 17.12.2025.
//
import SwiftUI
import CoreData

struct EmeraldPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    var displayMap: ((String) -> String)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .foregroundColor(.white.opacity(0.85))
                .font(.headline)

            Menu {
                ForEach(options, id: \.self) { item in
                    Button {
                        selection = item
                    } label: {
                        Text(displayMap?(item) ?? item)
                    }
                }
            } label: {
                HStack {
                    Text(
                        selection.isEmpty
                        ? "Таңдаңыз"
                        : (displayMap?(selection) ?? selection)
                    )
                    .foregroundColor(
                        .white.opacity(selection.isEmpty ? 0.5 : 1)
                    )

                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }
}
