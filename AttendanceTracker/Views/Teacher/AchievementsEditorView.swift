//
//  AchievementsEditorView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//
import SwiftUI
import PhotosUI

struct AchievementsEditorView: View {
    @Binding var items: [[String: Any]] // each: ["title": String, "photo": Data?]

    @State private var newTitle: String = ""
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var newPhotoData: Data?

    var body: some View {
        VStack {
            HStack {
                TextField("Марапат атауы", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    Image(systemName: "photo")
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(8)
                }
                .onChange(of: selectedPickerItem) { newItem in
                    Task { @MainActor in
                        if let item = newItem, let d = try? await item.loadTransferable(type: Data.self) {
                            newPhotoData = d
                        }
                    }
                }

                Button("Қосу") {
                    guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    var dict: [String: Any] = ["title": newTitle]
                    if let d = newPhotoData { dict["photo"] = d }
                    items.append(dict)
                    newTitle = ""
                    newPhotoData = nil
                    selectedPickerItem = nil
                }
            }.padding()

            List {
                ForEach(items.indices, id:\.self) { idx in
                    HStack {
                        if let data = items[idx]["photo"] as? Data, let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width:44, height:44)
                                .cornerRadius(6)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(width:44, height:44)
                                .cornerRadius(6)
                        }
                        Text(items[idx]["title"] as? String ?? "")
                        Spacer()
                        Button(role: .destructive) {
                            items.remove(at: idx)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete { offsets in items.remove(atOffsets: offsets) }
            }
        }
        .navigationTitle("Марапаттар")
    }
}
