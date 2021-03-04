//
//  ExperimentListView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct ExperimentListView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            HStack {
                Text("ColorScheme")
                Spacer(minLength: 20)
                Picker(selection: $appState.themeChoice, label: Text("ColorScheme")) {
                    Text("System").tag(ThemeChoice.system)
                    Text("Light").tag(ThemeChoice.light)
                    Text("Dark").tag(ThemeChoice.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Label("Prayer Times", systemImage: "sunrise")
                .navLink(PrayerTimesView())
            Label("Finder", systemImage: "folder")
                .navLink(FinderView())
            Label("BedTime Reminder", systemImage: "bed.double")
                .navLink(BedTimeView())
            Label("Weather", systemImage: "cloud.sun")
                .navLink(WeeklyWeatherView())
            Label("Random UI", systemImage: "scribble.variable")
                .navLink(RandomUI())
        }
    }
}

struct ExperimentListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperimentListView()
                .navigationTitle("Experiments")
        }
        .environmentObject(AppState())
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
