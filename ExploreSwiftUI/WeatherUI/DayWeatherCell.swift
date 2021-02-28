//
//  DayWeatherCell.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 17/1/21.
//

import SwiftUI

struct DayWeatherCell: View {
    let day: String
    let icon: String
    let temperature: Int
    
    var body: some View {
        VStack {
            Text(day)
                .font(.headline)
            Image(systemName: icon)
                .renderingMode(.original)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(8)
            Text("\(temperature)° C")
                .font(.subheadline)
        }
    }
}

struct DayWeatherCell_Previews: PreviewProvider {
    static var previews: some View {
        let days = [
            ("SAT", "cloud.sun.fill", 24),
            ("SUN", "sun.max.fill", 25),
            ("MON", "wind", 26),
            ("TUE", "sunset.fill", 26),
            ("WED", "moon.stars.fill", 27)
        ]
        
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
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
            .padding()
        }
    }
}
