//
//  ExploreSwiftUIApp.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 13/1/21.
//

import SwiftUI

@main
struct ExploreSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ExperimentListView()
                    .navigationTitle("Experiments")
            }
            .accentColor(Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
        }
    }
}
