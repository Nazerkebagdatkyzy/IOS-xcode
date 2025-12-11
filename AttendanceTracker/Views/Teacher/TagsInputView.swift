//
//  TagsInputView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//

import SwiftUI

struct TagsInputView: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Input row (unchanged logic, nicer styling)
            HStack(spacing: 10) {
                TextField("Жаңа дағды қосу", text: $newTag)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button("Қосу") {
                    let t = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    tags.append(t)
                    newTag = ""
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .cornerRadius(10)
            }

            // Tags grid — adaptive columns: wraps automatically and calculates height
            if !tags.isEmpty {
                // Use geometry to set full width grid
                GeometryReader { geo in
                    // adaptive GridItem with minimum width; it will wrap
                    let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                            ForEach(Array(tags.enumerated()), id: \.element) { index, tag in
                                HStack(spacing: 6) {
                                    Text(tag)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(Color.blue.opacity(0.12))
                                        .cornerRadius(16)

                                    Button(action: {
                                        if let i = tags.firstIndex(of: tag) {
                                            tags.remove(at: i)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, 0)
                        .frame(width: geo.size.width, alignment: .leading)
                    }
                }
                .frame(minHeight: 10, maxHeight: .infinity)
                .frame(height: calculatedGridHeight(for: tags)) // optional: give sensible height
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }

    // Optional helper: estimate height so container doesn't grow too tall.
    // This is conservative and keeps layout stable. You can remove and let it expand.
    private func calculatedGridHeight(for tags: [String]) -> CGFloat {
        // approximate: each row ~ 36pt height, compute number of rows by estimating tags per row
        // This is a simple heuristic; exact wrapping depends on device width.
        let estimatedTagsPerRow = 3.0 // adjust if you want tighter/wider
        let rows = ceil(Double(tags.count) / estimatedTagsPerRow)
        let rowHeight: Double = 36.0
        return CGFloat(rows * rowHeight)
    }
}
