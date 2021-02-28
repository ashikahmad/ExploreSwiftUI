//
//  FinderView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 28/2/21.
//

import SwiftUI

struct FinderView: View {
    var body: some View {
        VStack {
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
            
            Spacer()
        }
        .padding()
        .background(Color.blue.ignoresSafeArea())
        .navigationTitle("My Files")
    }
}

struct FinderView_Previews: PreviewProvider {
    static var previews: some View {
        FinderView()
    }
}
