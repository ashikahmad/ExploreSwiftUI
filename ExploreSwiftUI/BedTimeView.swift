//
//  BedTimeView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 26/2/21.
//

import SwiftUI
import Combine

struct BedTimeColorPalette {
    static let bgColor2: Color = Color(#colorLiteral(red: 0.1088567451, green: 0.1088567451, blue: 0.1088567451, alpha: 1))
    static let bgColor : Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let fgColor : Color = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    static let accent  : Color = Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
}

struct BedTimeView: View {
    
    @ObservedObject var data: BedTimeData
    
    // -----------------------------
    // MARK: - Make Input
    // -----------------------------
    
    fileprivate func makeInputSection() -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Image(systemName: "bed.double.fill")
                Text("BEDTIME")
                
                Spacer()
                
                Image(systemName: "bell.fill")
                Text("WAKE UP")
            }
            .padding(.horizontal, 8)
            
            HStack {
                DatePicker("Bed time", selection: $data.startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .background(BedTimeColorPalette.bgColor2)
                    .mask(Capsule())
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(BedTimeColorPalette.bgColor2)
                    .frame(height: 2)
                
                makeDurationText()
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(BedTimeColorPalette.bgColor2)
                    .frame(height: 2)
                
                DatePicker("Wake up time", selection: $data.endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .background(BedTimeColorPalette.bgColor2)
                    .mask(Capsule())
            }
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(BedTimeColorPalette.fgColor)
        .padding(.horizontal)
    }
    
    fileprivate func makeDurationText() -> some View {
        let hr = Int(data.duration)
        let min = Int((data.duration - floor(data.duration))*60)
        
        let hrStr = hr > 0 ? "\(hr) hr" : ""
        let minStr = min > 0 ? "\(min) min" : ""
        
        return Text([hrStr, minStr].joined(separator: " "))
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .layoutPriority(1)
    }
    
    // -----------------------------
    // MARK: - Body
    // -----------------------------
    
    init() {
        let startDate: Date = Date(
            timeInterval: 0 * 3600,
            since: Date.today)
        
        let endDate: Date = Date(
            timeInterval: 6.4 * 3600,
            since: Date.today)
        
        data = BedTimeData(
            startTime: startDate,
            endTime: endDate)
    }
    
    var body: some View {
        
        VStack {
            Spacer()
            
            makeInputSection()
            BedTimeDial(data: data)
            
            Spacer()
        }
        .background(BedTimeColorPalette.bgColor.ignoresSafeArea())
    }
}

struct BedTimeView_Previews: PreviewProvider {
    static var previews: some View {
        BedTimeView()
    }
}

// ---------------------------------------------------
// MARK: - BedTime Dial
// ---------------------------------------------------

class BedTimeData: ObservableObject {
    @Published var startTime: Date
    @Published var endTime: Date
    
    var duration: Double {
        var d = endHour - startHour
        if d < 0 { d += 24 }
        return d
    }
    
    var startHour: Double {
        startTime.timeIntervalSince(Date.today)/3600
    }
    var endHour: Double {
        endTime.timeIntervalSince(Date.today)/3600
    }
    
    init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
    }
}

struct BedTimeDial: View {
    @ObservedObject var data: BedTimeData
    
    let sliderRingWidth: CGFloat = 40
    let sliderPadding: CGFloat = 5
    let sliderInnerPadding: CGFloat = 10
    
    let tickerPadding: CGFloat = 5
    let majorTickerWidth: CGFloat = 15
    let mediumTickerWidth: CGFloat = 10
    let minorTickerWidth: CGFloat = 2
    
    var startFrac: CGFloat { CGFloat(data.startHour / 24) }
    var durationFrac: CGFloat { CGFloat(data.duration / 24) }
    var startDegree: Double { Double(360 * startFrac) }
    var durationDegree: Double { Double(360 * durationFrac) }
    
    var labelsPadding: CGFloat {
        return sliderRingWidth
            + sliderPadding * 2
            + tickerPadding * 2
            + majorTickerWidth
    }
    
    @State private var totalWidth: CGFloat = 0
    
    var sliderRadius: CGFloat {
        return totalWidth/2
            - sliderPadding
            - sliderRingWidth / 2
    }
    
    private func change(location: CGPoint) {
        let knobW = sliderRingWidth - sliderInnerPadding*2
        let x = location.x - knobW
        let y = location.y - sliderRadius - knobW
        
        let a = angle(for: CGSize(width: x, height: y))
        let hr = angleToHours(a)
        
        if currentDrag == .start {
            data.startTime = Date(hours: hr)
        } else {
            data.endTime = Date(hours: hr)
        }
    }
    
    func hoursToAngle(_ hours: Double) -> Angle {
        return .degrees(hours*360/24)
    }
    
    func angleToHours(_ angle: Angle) -> Double {
        return angle.degrees*24/360
    }
    
    func translation(for angle: Angle) -> CGSize {
        let r = Double(sliderRadius)
        let A = angle.radians - .pi/2
        let h = r * sin(A)
        let w = r * cos(A)
        return CGSize(width: w, height: h)
    }
    
    func angle(for translation: CGSize) -> Angle {
        var a = atan2(translation.height,  translation.width) + .pi/2
        if a < 0 { a += .pi*2 }
        return .radians(Double(a))
    }
    
    var body: some View {
        ZStack {
            Color.clear.frame(height: 1).readSize {
                totalWidth = $0.width
            }
            makeSlider()
            
            // Dial BG
            Circle()
                .inset(by: sliderRingWidth
                        + sliderPadding * 2)
                .foregroundColor(BedTimeColorPalette.bgColor)
            
            makeTickers()
            makeSecondaryLabels()
            makePrimaryLabels()
        }
        .padding(20)
        .aspectRatio(1, contentMode: .fit)
    }
    
    // -----------------------------
    // MARK: - Make Slider
    // -----------------------------
    
    private enum DragType {
        case none, start, end
    }
    @State private var currentDrag: DragType = .none
    
    fileprivate func makeKnobs() -> some View {
        // Knobs
        let knobData: [(String, Double, DragType)] = [
            ("bed.double.fill", 0, .start),
            ("bell.fill", durationDegree, .end)
        ]
        
        return ForEach(knobData, id: \.0) { icon, angle, dragType in
            Image(systemName: icon)
                .resizable()
                .padding(2)
                .frame(width: sliderRingWidth - sliderInnerPadding*2)
                .padding(sliderInnerPadding - 2)
                .background(
                    Circle()
                        .foregroundColor(currentDrag == .none ? .clear : BedTimeColorPalette.bgColor2))
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(BedTimeColorPalette.fgColor)
                .rotationEffect(.degrees(-angle - startDegree + 90))
                .offset(x: sliderRadius)
                .rotationEffect(.degrees(angle + startDegree - 90))
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    currentDrag = dragType
                    change(location: value.location)
                }.onEnded({ _ in
                    currentDrag = .none
                }))
        }
    }
    
    fileprivate func makeSlider() -> some View {
        ZStack {
            // Slider Ring
            Circle()
                .foregroundColor(BedTimeColorPalette.bgColor2)
            
            // Slider Fill
            Circle()
                .inset(by: sliderPadding + sliderRingWidth/2)
                .trim(from: 0, to: durationFrac)
                .stroke(style: StrokeStyle(
                    lineWidth: sliderRingWidth,
                    lineCap: .round,
                    lineJoin: .round
                ))
                .foregroundColor(
                    currentDrag == .none
                        ? BedTimeColorPalette.bgColor
                        : .accentColor)
                .rotationEffect(.degrees(startDegree-90))
            
            // Slider Dashes
            Circle()
                .inset(by: sliderPadding + sliderRingWidth/2)
                .trim(from: 0.015,
                      to: durationFrac - 0.015)
                .stroke(style: StrokeStyle(
                    lineWidth: sliderRingWidth - sliderInnerPadding*2,
                    dash: [2, 4]
                ))
                .foregroundColor(BedTimeColorPalette.bgColor2)
                .rotationEffect(.degrees(startDegree-90))
            
            makeKnobs()
        }
    }
    
    // -----------------------------
    // MARK: - Make Dial
    // -----------------------------
    
    fileprivate func makeTickers() -> some View {
        // Tickers
        ForEach(0..<120) { index in
            HStack {
                let width: CGFloat = {
                    switch index {
                    case let x where x % 10 == 0:
                        return majorTickerWidth
                    case let x where x % 5 == 0:
                        return mediumTickerWidth
                    default:
                        return minorTickerWidth
                    }
                }()
                
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: width,
                           height: 2)
                    .foregroundColor(BedTimeColorPalette.bgColor2)
            }
            .padding(
                sliderRingWidth
                    + sliderPadding*2
                    + tickerPadding)
            .rotationEffect(.degrees(360*Double(index)/120))
        }
    }
    
    fileprivate func makePrimaryLabels() -> some View {
        // Labels
        VStack(spacing: 4) {
            Text("12 AM")
            Image(systemName: "moon.circle.fill")
                .renderingMode(.original)
            Spacer()
            HStack {
                Text("6 PM")
                Spacer()
                Text("6 AM")
            }
            Spacer()
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
            Text("12 PM")
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(BedTimeColorPalette.fgColor)
        .padding(labelsPadding)
        .aspectRatio(1, contentMode: .fit)
    }
    
    func makeSecondaryLabels() -> some View {
        ZStack {
            ForEach(0..<12) { index in
                let angle = Double(index * 30)
                let hr = index * 2
                let label = String(hr > 12 ? hr - 12 : hr)
                
                if index % 3 == 0 {
                    EmptyView()
                } else {
                    Text(label)
                        .rotating(
                            angle: angle - 90,
                            padding: labelsPadding)
                }
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(BedTimeColorPalette.bgColor2)
        }
    }
    
}

// ---------------------------------------------------
// MARK: - Extensions
// ---------------------------------------------------

extension Date {
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var hours: Double {
        let startOfDay = Calendar.current.startOfDay(for: self)
        return timeIntervalSince(startOfDay)/3600
    }
    
    init(hours: Double) {
        self.init(timeInterval: hours * 3600,
             since: Date.today)
    }
}

extension View {
    func rotating(angle: Double, padding: CGFloat) -> some View {
        HStack {
            Spacer()
            self.rotationEffect(.degrees(-angle))
        }
        .padding(padding)
        .rotationEffect(.degrees(angle))
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

extension CGPoint {
    func asSize() -> CGSize {
        return CGSize(width: x, height: y)
    }
    
    func adding(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: x + other.x, y: y + other.y)
    }
}
