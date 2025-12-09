//
//  PDFExporter.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//
import UIKit
import SwiftUI
import PDFKit

class PDFExporter {
    // Simple PDF creation from UIKit drawing
    // Returns local temp file URL
    func exportTeacherResumeToPDF(teacher: Teacher, profileImage: UIImage?, about: String, education: String, experience: Int, skills: [String], achievements: [[String:Any]], certificates: [String], socialLinks: [String]) -> URL? {
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let pdfMeta = [
            kCGPDFContextCreator: "AttendanceTracker",
            kCGPDFContextAuthor: teacher.name ?? ""
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMeta as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x:0,y:0,width:pageWidth,height:pageHeight), format: format)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 20

            // Draw header (photo + name)
            if let img = profileImage {
                let rect = CGRect(x: 20, y: y, width: 80, height: 80)
                img.draw(in: rect)
            } else {
                // placeholder
            }
            let nameRect = CGRect(x: 110, y: y, width: pageWidth - 130, height: 30)
            let name = teacher.name ?? "Аты белгісіз"
            name.draw(in: nameRect, withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])

            y += 40
            let emailRect = CGRect(x: 110, y: y, width: pageWidth - 130, height: 20)
            (teacher.email ?? "").draw(in: emailRect, withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            y += 26

            // About
            let aboutTitle = "Өзі туралы"
            aboutTitle.draw(in: CGRect(x: 20, y: y, width: 200, height: 18), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            y += 20
            let aboutRect = CGRect(x:20, y:y, width: pageWidth - 40, height: 100)
            about.draw(in: aboutRect, withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            y += 104

            // Education, Experience, Skills
            let eduTitle = "Білімі: \(education)"
            eduTitle.draw(in: CGRect(x:20,y:y,width: pageWidth - 40, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            y += 20
            let expTitle = "Өтілі: \(experience) жыл"
            expTitle.draw(in: CGRect(x:20,y:y,width: pageWidth - 40, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            y += 22

            if !skills.isEmpty {
                let skillsTitle = "Дағдылар: " + skills.joined(separator: ", ")
                skillsTitle.draw(in: CGRect(x:20,y:y,width: pageWidth - 40, height: 40), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                y += 44
            }

            // Achievements (titles)
            if !achievements.isEmpty {
                "Марапаттар:".draw(in: CGRect(x:20,y:y,width:200,height:18), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)])
                y += 20
                for ach in achievements {
                    if y > pageHeight - 120 { ctx.beginPage(); y = 20 } // new page
                    let t = ach["title"] as? String ?? ""
                    t.draw(in: CGRect(x:24,y:y,width: pageWidth - 48, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                    y += 20
                }
            }

            // Certificates
            if !certificates.isEmpty {
                if y > pageHeight - 120 { ctx.beginPage(); y = 20 }
                "Сертификаттар:".draw(in: CGRect(x:20,y:y,width:200,height:18), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)])
                y += 20
                for c in certificates {
                    if y > pageHeight - 120 { ctx.beginPage(); y = 20 }
                    c.draw(in: CGRect(x:24,y:y,width: pageWidth - 48, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                    y += 18
                }
            }

            // Social Links
            if !socialLinks.isEmpty {
                if y > pageHeight - 120 { ctx.beginPage(); y = 20 }
                "Әлеуметтік желілер:".draw(in: CGRect(x:20,y:y,width:200,height:18), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)])
                y += 20
                for s in socialLinks {
                    if y > pageHeight - 120 { ctx.beginPage(); y = 20 }
                    s.draw(in: CGRect(x:24,y:y,width: pageWidth - 48, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                    y += 18
                }
            }
        }

        // Save to tmp file
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("TeacherResume-\(UUID().uuidString).pdf")
        do {
            try data.write(to: tmp)
            return tmp
        } catch {
            print("PDF write error:", error)
            return nil
        }
    }
}

// Share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

