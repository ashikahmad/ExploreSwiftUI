//
//  PrayerTimesView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct PrayerTimesView: View {
    var body: some View {
        List {
            let times = PrayerService.timesToday()
                .map { ($0.key, $0.value) }
                .sorted { $0.0 < $1.0 }
            
            VStack(spacing: 8) {
                ForEach(times, id: \.0.name) {
                    WaqtRow(waqt: $0.0, time: $0.1)
                }
            }
            .padding()
            .listRowInsets(.zero)
            .background(Color.systemBackground)
        }
        .navigationTitle("Prayer Time")
    }
}

struct PrayerTimesView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimesView().colorScheme(.light)
        PrayerTimesView().colorScheme(.dark)
    }
}

extension EdgeInsets {
    
    static var zero: Self { return EdgeInsets(all: 0) }
    
    init(all: CGFloat) {
        self.init(horizontal: 0, vertical: 0)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

/*
 * 
 */
