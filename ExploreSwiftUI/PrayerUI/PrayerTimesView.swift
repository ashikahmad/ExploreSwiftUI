//
//  PrayerTimesView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct PrayerTimesView: View {
    var body: some View {
        ZStack {
            let times = PrayerService.timesToday()
                .map { ($0.key, $0.value) }
                .sorted { $0.0 < $1.0 }
            
            Color.blue
                .ignoresSafeArea()
            VStack(spacing: 2) {
                ForEach(times, id: \.0.name) {
                    WaqtRow(waqt: $0.0, time: $0.1)
                }
            }
            .padding()
        }
        .navigationTitle("Prayer Time")
    }
}

struct PrayerTimesView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimesView()
    }
}
