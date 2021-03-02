//
//  WeeklyWeatherView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct WeeklyWeatherView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let days = [
            ("SAT", "cloud.sun.fill", 24),
            ("SUN", "sun.max.fill", 25),
            ("MON", "wind", 26),
            ("TUE", "sunset.fill", 26),
            ("WED", "moon.stars.fill", 27)
        ]
        
        ScrollView {
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
            .padding()
            .background(colorScheme == .light
                            ? Color.blue
                            : Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            
            Spacer()
        }
        .background(Color.systemBackground.ignoresSafeArea())
        
        .navigationTitle("Weather")
    }
}

struct WeeklyWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyWeatherView().colorScheme(.light)
        WeeklyWeatherView().colorScheme(.dark)
    }
}
