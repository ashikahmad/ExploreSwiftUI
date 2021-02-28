//
//  Folder.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 17/1/21.
//

import SwiftUI

struct Folder: View {
    let icon: String
    let color: Color
    
    init(icon: String, color: Color = .yellow) {
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        
        SingleAxisGeometryReader { width in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                let w: CGFloat = width
                let aspectRatio: CGFloat = 3/4
                let h: CGFloat = w * aspectRatio
                
                RoundedRectangle(cornerRadius: w * 0.05)
                    .fill(color.darker(by: 10))
                    .frame(width: w * 0.4,
                           height: w * 0.4)
                    .padding(.leading, w * 0.05)
                
                RoundedRectangle(cornerRadius: w * 0.1)
                    .fill(color)
                    .frame(width: w,
                           height: h - w * 0.06)
                    .padding(.top, w * 0.06)
                
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(color.darker(by: 25))
                    .frame(width: 20, height: 20)
                    .padding(.leading, w * 0.1)
                    .frame(height: h - w * 0.1,
                           alignment: .bottomLeading)
            }
        }
    }
}

struct Folder_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([false, true], id: \.self) { isDark in
            ZStack {
                Color(UIColor.systemBackground)

                VStack {
                    Folder(icon: "photo")
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Images")
                        .font(.system(.subheadline))
                }
            }
            .previewLayout(.fixed(width: 150, height: 150))
            .colorScheme(isDark ? .dark : .light)
        }
        
    }
}
