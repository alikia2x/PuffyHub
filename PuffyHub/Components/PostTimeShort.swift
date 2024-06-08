//
//  PostTimeShort.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

import Foundation
import SwiftUI

struct PostTimeShort: View {
    var time: String
    @State private var relativeTime = ""
    @State private var timerInterval: TimeInterval = 1
    @State private var timer: Timer? = Timer()
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            updateRelativeTime()
            adjustTimerInterval()
        }
    }
    
    private func updateRelativeTime() {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoDateFormatter.date(from: time) {
            let relativeFormatter = RelativeDateTimeFormatter()
            relativeFormatter.unitsStyle = .full
            relativeFormatter.locale = Locale.current
            relativeTime = relativeFormatter.localizedString(for: date, relativeTo: Date())
        } else {
            relativeTime = "Invalid date"
        }
    }
    
    private func adjustTimerInterval() {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoDateFormatter.date(from: time) {
            timerInterval = Date().timeIntervalSince(date) >= 60 ? 60 : 1
            startTimer()
        }
    }
    
    var body: some View {
        Text(relativeTime)
            .font(.caption)
            .foregroundStyle(.secondary)
            .onAppear {
                updateRelativeTime()
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
}


#Preview {
    PostTimeShort(time: "2024-06-08T07:03:20.158Z")
}
