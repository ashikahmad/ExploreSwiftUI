//
//  RandomUI.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 5/3/21.
//

import SwiftUI

struct RandomUI: View {
    @State private var alarm: Bool = true
    @State private var buttonShape: ButtonShape = .capsule
    @State private var corner: CGFloat = 8
    
    var body: some View {
        VStack {
            HStack {
                Text("Shape")
                Spacer(minLength: 20)
                Picker(selection: $buttonShape, label: Text("ColorScheme")) {
                    Text("Circle").tag(ButtonShape.circle)
                    Text("Capsule").tag(ButtonShape.capsule)
                    Text("Rect").tag(ButtonShape.roundedRect(0))
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if buttonShape.isRoundedRect {
                HStack {
                    Text("Corner Radius")
                    Spacer(minLength: 20)
                    Slider(value: $corner, in: 0...30)
                    Text("\(corner, specifier: "%.1f")")
                }
            }
            
            Divider()
            
            makeRaisedButton()
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func makeRaisedButton() -> some View {
        Button(action: { alarm.toggle() }) {
            Image(systemName: alarm ? "bell" : "bell.slash")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .frame(width: 100)
                .padding(8)
        }
        .buttonStyle(
            RaisedButtonStyle(
                color: Binding<Color>(
                    get: { alarm ? .blue : .red },
                    set: { _ in })
            )
            .shape({
                switch buttonShape {
                case .circle, .capsule: return buttonShape
                case .roundedRect(_): return .roundedRect(corner)
                }
            }())
        )
    }
}

struct RandomUI_Previews: PreviewProvider {
    static var previews: some View {
        RandomUI()
    }
}

enum ButtonShape: Hashable {
    case circle
    case capsule
    case roundedRect(CGFloat)
    
    var isRoundedRect: Bool {
        switch self {
        case .circle, .capsule: return false
        case .roundedRect: return true
        }
    }
}

struct RaisedButtonStyle: ButtonStyle {
    let raiseAmount: CGFloat = 4
    let pressedRaiseAmount: CGFloat = 2
    var shape: ButtonShape = .circle
    
    @Binding var color: Color
    
    private func makeBGShape() -> AnyView {
        switch shape {
        case .circle: return AnyView(Circle())
        case .capsule: return AnyView(Capsule())
        case .roundedRect(let radius):
            return AnyView(RoundedRectangle(cornerRadius: radius))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(
                makeBGShape()
                    .foregroundColor(color)
            )
            .background(
                makeBGShape()
                    .foregroundColor(color.darker())
                    .offset(y: configuration.isPressed
                                ? pressedRaiseAmount
                                : raiseAmount)
            )
            .offset(y: configuration.isPressed
                        ? -pressedRaiseAmount
                        : -raiseAmount)
    }
    
    func shape(_ buttonShape: ButtonShape) -> Self {
        var new = self
        new.shape = buttonShape
        return new
    }
}
