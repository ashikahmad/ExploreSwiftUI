//
//  ExperimentListView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct ExperimentListView: View {
    var body: some View {
        List {
            Text("Prayer Times")
                .navLink(PrayerTimesView())
            Text("Finder")
                .navLink(FinderView())
            Text("BedTime Reminder")
                .navLink(BedTimeView())
            Text("Weather")
                .navLink(WeeklyWeatherView())
        }
    }
}

struct ExperimentListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperimentListView()
                .navigationTitle("Experiments")
        }
    }
}

extension View {
    func navLink<Destination: View>(_ destination: Destination) -> some View {
        NavigationLink(
            destination: destination,
            label: {
                self
            })
    }
}
