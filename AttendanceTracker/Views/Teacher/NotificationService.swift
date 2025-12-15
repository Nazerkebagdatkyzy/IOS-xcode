//
//  NotificationService.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 15.12.2025.
//

import UserNotifications

final class NotificationService {

    // 🔐 Permission сұрау
    static func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("🔔 Notification permission GRANTED")
                } else {
                    print("🔕 Notification permission DENIED")
                }

                if let error = error {
                    print("❌ Notification error:", error)
                }
            }
    }

    // 📩 Absent notification
    static func notifyAbsent(studentName: String, className: String) {
        let content = UNMutableNotificationContent()
        content.title = "Сабаққа келмеді"
        content.body = "\(studentName) (\(className)) бүгін сабаққа келмеді"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
