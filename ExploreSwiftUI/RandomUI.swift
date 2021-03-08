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
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                VCell(title: "Shape") {
                    Picker(selection: $buttonShape, label: Text("Shape")) {
                        Text("Circle").tag(ButtonShape.circle)
                        Text("Capsule").tag(ButtonShape.capsule)
                        Text("Rect").tag(ButtonShape.roundedRect(0))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if buttonShape.isRoundedRect {
                    VCell(title: "Corner Radius") {
                        HStack {
                            Slider(value: $corner, in: 0...30)
                            Text("\(corner, specifier: "%.1f")")
                        }
                    }
                }
                
                Spacer().frame(height: 25)
            }
            .padding(.horizontal)
            .background(
                CurveSidedRect(curveHeight: 30)
                    .padding(.horizontal, -5)
                    .foregroundColor(Color(.tertiarySystemBackground))
                    .ignoresSafeArea()
                    .shadow(radius: 4, y: 6)
            )
            
            makeRaisedButton()
                .padding(40)
            
            Spacer()
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationBarTitle("")
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
        NavigationView {
            RandomUI()
        }
    }
}

// -----------------------------------------------------------
// MARK: - Raised Button
// -----------------------------------------------------------
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

// -----------------------------------------------------------
// MARK: - Custom Shape Experiment
// -----------------------------------------------------------

struct CurveSidedRect: Shape {
    var curveHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            let cH = min(curveHeight, rect.height)
            let curveRect = CGRect(
                origin: rect.bottomLeft.offset(y: -cH),
                size: CGSize(width: rect.width, height: cH))
            
            p.move(to: rect.topLeft)
            p.addLine(to: rect.topRight)
            p.addLine(to: curveRect.topRight)
            p.addQuadCurve(to: curveRect.topLeft,
                           control: controlPoint(for: curveRect))
            p.closeSubpath()
        }
    }
    
    func controlPoint(for rect: CGRect) -> CGPoint {
        let x = rect.width/2
        let h = rect.height
        let r = (x*x + h*h) / 2*h
        let oc = r*r / (r - h)
        
        return CGPoint(x: rect.midX, y: rect.maxY + oc - r)
    }
}

// -----------------------------------------------------------
// MARK: - Convenience - Views
// -----------------------------------------------------------

struct VCell<ValueView: View>: View {
    let title: String
    let valueBuilder: ()->ValueView
    
    init(title: String, @ViewBuilder value: @escaping ()->ValueView ) {
        self.title = title
        self.valueBuilder = value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.leading, 4)
            
            valueBuilder()
        }
    }
}

// -----------------------------------------------------------
// MARK: - Convenience - Extensions
// -----------------------------------------------------------

extension CGRect {
    var topLeft: CGPoint { CGPoint(x: minX, y: minY) }
    var topRight: CGPoint { CGPoint(x: maxX, y: minY) }
    var top: CGPoint { CGPoint(x: midX, y: minY) }
    
    var bottomLeft: CGPoint { CGPoint(x: minX, y: maxY) }
    var bottomRight: CGPoint { CGPoint(x: maxX, y: maxY) }
    var bottom: CGPoint { CGPoint(x: midX, y: maxY) }
    
    var left: CGPoint { CGPoint(x: minX, y: midY) }
    var right: CGPoint { CGPoint(x: maxX, y: midY) }
}

extension CGPoint {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}
