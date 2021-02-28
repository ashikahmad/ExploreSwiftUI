//
//  PrayerService.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 25/1/21.
//

import Foundation

class PrayerService {
    static func timesToday() -> [Waqt: String] {
        return [
            .fajr: "5:23 AM",
            .duhr: "12:07 PM",
            .asr: "3:55 PM",
            .maghrib: "5:31 PM",
            .isha: "6:51 PM"
        ]
    }
}
