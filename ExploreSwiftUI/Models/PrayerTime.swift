//
//  PrayerTime.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 25/1/21.
//

import Foundation

enum Waqt: CaseIterable, Comparable {
    case fajr, duhr, asr, maghrib, isha
    
    var name: String {
        return String(describing: self)
    }
    
    var icon: String {
        switch self {
        case .fajr: return "sunrise"
        case .duhr: return "sun.max"
        case .asr: return "sun.min"
        case .maghrib: return "sunset"
        case .isha: return "moon"
        }
    }
}



