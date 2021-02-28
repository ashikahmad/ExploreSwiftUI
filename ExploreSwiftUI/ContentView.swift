//
//  ContentView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 13/1/21.
//

import SwiftUI

struct ContentView: View {
    let times = PrayerService.timesToday()
        .map { ($0.key, $0.value) }
        .sorted { $0.0 < $1.0 }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color("lightSky")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 2) {
                    let folders: [(String, Color, String)] = [
                        ("photo", .yellow, "Images"),
                        ("swift", .orange, "Swift"),
                        ("video.circle.fill", .pink, "Videos"),
                        ("network", .purple, "Network"),
                        ("gamecontroller.fill", .green, "Games"),
                        ("lightbulb.fill", .yellow, "Ideas"),
                        ("airplane", Color(.systemTeal), "Travels"),
                        ("trash", Color(.systemGray4), "Trash")
                    ]
                    
                    HStack {
                        ForEach(folders.prefix(4), id: \.2) { icon, color, title in
                            VStack {
                                Folder(icon: icon, color: color)
                                Text(title)
                                    .foregroundColor(.white)
                            }
                        }
                    }.padding(.bottom, 8)
                    
                    HStack {
                        ForEach(folders.suffix(4), id: \.2) { icon, color, title in
                            VStack {
                                Folder(icon: icon, color: color)
                                Text(title)
                                    .foregroundColor(.white)
                            }
                        }
                    }.padding(.bottom, 8)
                    
                    ForEach(times, id: \.0.name) { waqt, time in
                        WaqtRow(waqt: waqt, time: time)
                    }
                    
                    let days = [
                        ("SAT", "cloud.sun.fill", 24),
                        ("SUN", "sun.max.fill", 25),
                        ("MON", "wind", 26),
                        ("TUE", "sunset.fill", 26),
                        ("WED", "moon.stars.fill", 27)
                    ]
                    
                    HStack {
                        ForEach(days, id: \.0) { day, icon, temp in
                            DayWeatherCell(
                                day: day,
                                icon: icon,
                                temperature: temp)
                            
                            if day != days.last?.0 {
                                Spacer()
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle(Text("SwiftUI"), displayMode: .inline)
            .navigationViewStyle(DefaultNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


