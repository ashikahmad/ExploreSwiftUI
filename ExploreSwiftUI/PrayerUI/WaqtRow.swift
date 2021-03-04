//
//  WaqtRow.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 17/1/21.
//

import SwiftUI

struct WaqtRow: View {
    let waqt: Waqt
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(waqt.name.capitalized)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .fontWeight(.bold)
                
                Text(time)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: waqt.icon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(5.0)
    }
}

struct WaqtRow_Previews: PreviewProvider {
    static var previews: some View {
        let times = PrayerService.timesToday()
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
        
        ZStack {
//            Color.blue
//                .ignoresSafeArea()
            VStack(spacing: 2) {
                ForEach(times, id: \.0.name) {
                    WaqtRow(waqt: $0.0, time: $0.1)
                }
            }
            .padding()
        }
    }
}
