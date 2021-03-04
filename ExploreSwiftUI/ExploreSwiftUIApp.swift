//
//  ExploreSwiftUIApp.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 13/1/21.
//

import SwiftUI

enum ThemeChoice {
    case system, light, dark
}

class AppState: ObservableObject {
    @Published var themeChoice: ThemeChoice = .system
}

@main
struct ExploreSwiftUIApp: App {
    
    var body: some Scene {
        WindowGroup {
            AppContent()
        }
    }
}

struct AppContent: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var appState = AppState()
    
    var body: some View {
        NavigationView {
            ExperimentListView()
                .navigationTitle("Experiments")
        }
        .environment(\.colorScheme, {
            switch appState.themeChoice {
            case .system: return colorScheme
            case .light: return .light
            case .dark: return .dark
            }
        }())
        .environmentObject(appState)
    }
}
