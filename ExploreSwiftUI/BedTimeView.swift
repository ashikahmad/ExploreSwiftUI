//
//  BedTimeView.swift
//  ExploreSwiftUI
//
//  Created by Ashik Uddin on 26/2/21.
//

import SwiftUI
import Combine

// ---------------------------------------------------
// MARK: - Constants
// ---------------------------------------------------

fileprivate struct ColorPalette {
    // background
    //  - card
    // secondary background color
    //  - Slider ring background color
    //  - Input time picker background color
    //  - Knob background color when dragging
    // tertiary background color
    //  - Slider handle color
    //  - Dial background color
    // foreground color
    //  - Input Labels
    //  - Primary Labels
    //  - Knob Icons
    // secondary foreground color
    //  - Secondary Labels
    // tertiary foreground color
    //  - ticker color
    //  - slider dash color
    
    let background : Color
    let background2: Color
    let background3: Color
    let foreground : Color
    let foreground2: Color
    let foreground3: Color
    
    static let dark = ColorPalette(
        background : Color(.systemGray5),
        background2: Color(.systemGray6),
        background3: Color(.systemGray5),
        foreground : Color(.label),
        foreground2: Color(.secondaryLabel),
        foreground3: Color(.tertiaryLabel)
    )
    
    static let light = ColorPalette(
        background : Color(.systemGray5),
        background2: Color(.systemGray4),
        background3: Color(.systemGray6),
        foreground : Color(.label),
        foreground2: Color(.secondaryLabel),
        foreground3: Color(.tertiaryLabel)
    )
    
    static subscript (_ scheme: ColorScheme) -> Self {
        switch scheme {
        case .light: return light
        case .dark: return dark
        @unknown default: return light
        }
    }
}

// ---------------------------------------------------
// MARK: - Data
// ---------------------------------------------------

class BedTimeData: ObservableObject {
    @Published var startTime: Date {
        didSet { adjustDurationIfNeeded(anchoringStartTime: true) }
    }
    @Published var endTime: Date {
        didSet { adjustDurationIfNeeded(anchoringStartTime: false) }
    }
    
    var minDuration: Double = 1
    var maxDuration: Double = 20
    
    var duration: Double {
        return (endHour - startHour).fixHour()
    }
    
    var startHour: Double { startTime.hours }
    var endHour: Double { endTime.hours }
    
    init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    private var isAdjusting = false
    
    private func adjustDurationIfNeeded(anchoringStartTime: Bool) {
        guard !isAdjusting else { return }
        isAdjusting = true
        
        if duration < minDuration {
            if anchoringStartTime {
                endTime = Date(hours: (startTime.hours + minDuration).fixHour())
            } else {
                startTime = Date(hours: (endTime.hours - minDuration).fixHour())
            }
        } else if duration > maxDuration {
            if anchoringStartTime {
                endTime = Date(hours: (startTime.hours + maxDuration).fixHour())
            } else {
                startTime = Date(hours: (endTime.hours - maxDuration).fixHour())
            }
        }
        
        isAdjusting = false
    }
}

// ---------------------------------------------------
// MARK: - Dial
// ---------------------------------------------------

struct BedTimeDial: View {
    @Environment(\.colorScheme) var colorScheme
    
    private enum DragType: Equatable {
        case none, start, end, slider(Double, Double)
        
        static func == (lhs: DragType, rhs: DragType) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none),
                 (.start, .start),
                 (.end, .end): return true
                
            case let (.slider(lStart, lEnd), .slider(rStart, rEnd)):
                return (lStart, lEnd) == (rStart, rEnd)
                
            default:
                return false
            }
        }
    }
    
    @ObservedObject var data: BedTimeData
    
    @State private var totalWidth: CGFloat = 0
    @State private var currentDrag: DragType = .none
    
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
    
    var sliderRadius: CGFloat {
        return totalWidth/2
            - sliderPadding
            - sliderRingWidth / 2
    }
    
    private func change(location: CGPoint) {
        let knobW = sliderRingWidth - sliderInnerPadding*2
        let x = location.x - knobW
        let y = location.y - sliderRadius - knobW
        
        let angle = translationToAngle(CGSize(width: x, height: y))
        let hr = angleToHours(angle)
        
        if currentDrag == .start {
            data.startTime = Date(hours: hr)
        } else {
            data.endTime = Date(hours: hr)
        }
    }
    
    private func moveSlider(location: CGPoint, startLocation: CGPoint) {
        let knobW = sliderRingWidth - sliderInnerPadding*2
        
        if currentDrag == .none {
            let sx = startLocation.x - sliderRadius - knobW
            let sy = startLocation.y - sliderRadius - knobW
            
            let sAngle = translationToAngle(CGSize(width: sx, height: sy))
            let sHr = angleToHours(sAngle)
            
            var startDiff = (sHr - data.startHour)
            if startDiff > 0 { startDiff -= 24 }
            
            var endDiff = (data.endHour - sHr)
            if endDiff < 0 { endDiff += 24 }
            
            currentDrag = .slider(startDiff, endDiff)
        }
        
        guard case let .slider(startDiff, endDiff) = currentDrag
        else { return }
        
        let x = location.x - sliderRadius - knobW
        let y = location.y - sliderRadius - knobW
        
        let angle = translationToAngle(CGSize(width: x, height: y))
        let hr = angleToHours(angle)
        
        data.startTime = Date(hours: (hr - startDiff).fixHour())
        data.endTime = Date(hours: (hr + endDiff).fixHour())
    }
    
    // -----------------------------
    // MARK: Conversions
    // -----------------------------
    
    private func hoursToAngle(_ hours: Double) -> Angle {
        return .degrees(hours*360/24)
    }
    
    private func angleToHours(_ angle: Angle) -> Double {
        return angle.degrees*24/360
    }
    
    private func angleToTranslation(_ angle: Angle) -> CGSize {
        let r = Double(sliderRadius)
        let A = angle.radians - .pi/2
        let h = r * sin(A)
        let w = r * cos(A)
        return CGSize(width: w, height: h)
    }
    
    private func translationToAngle(_ translation: CGSize) -> Angle {
        var a = atan2(translation.height,  translation.width) + .pi/2
        if a < 0 { a += .pi*2 }
        return .radians(Double(a))
    }
    
    // -----------------------------
    // MARK: Dial Body
    // -----------------------------
    
    var body: some View {
        ZStack {
            Color.clear.frame(height: 1).readSize {
                totalWidth = $0.width
            }
            
            // Slider Ring
            Circle()
                .foregroundColor(ColorPalette[colorScheme].background2)
            
            // Dial BG
            Circle()
                .inset(by: sliderRingWidth
                        + sliderPadding * 2)
                .foregroundColor(ColorPalette[colorScheme].background3)
            
            makeSlider()
            
            makeTickers()
            makeSecondaryLabels()
            makePrimaryLabels()
        }
        .padding(8)
        .aspectRatio(1, contentMode: .fit)
    }
    
    // -----------------------------
    // MARK: Make Slider
    // -----------------------------
    
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
                        .foregroundColor(
                            currentDrag == .none
                                ? .clear
                                : ColorPalette[colorScheme].background2))
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(ColorPalette[colorScheme].foreground2)
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
                        ? ColorPalette[colorScheme].background3
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
                .foregroundColor(ColorPalette[colorScheme].background2)
                .rotationEffect(.degrees(startDegree-90))
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    moveSlider(
                        location: value.location,
                        startLocation: value.startLocation)
                }.onEnded { _ in
                    currentDrag = .none
                })
            
            makeKnobs()
        }
    }
    
    // -----------------------------
    // MARK: Make Dial
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
                    .foregroundColor(ColorPalette[colorScheme].foreground3)
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
                .font(.subheadline)
            Spacer()
            HStack {
                Text("6 PM")
                Spacer()
                Text("6 AM")
            }
            Spacer()
            Image(systemName: "sun.max.fill")
                .foregroundColor(.yellow)
                .font(.subheadline)
            Text("12 PM")
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(ColorPalette[colorScheme].foreground)
        .padding(labelsPadding)
        .aspectRatio(1, contentMode: .fit)
    }
    
    fileprivate func makeSecondaryLabels() -> some View {
        ZStack {
            ForEach(0..<12) { index in
                let angle = Double(index * 30)
                let hr = index * 2
                let label = String(hr > 12 ? hr - 12 : hr)
                
                if index % 3 == 0 {
                    EmptyView()
                } else {
                    Text(label).rotating(
                        angle: angle - 90,
                        padding: labelsPadding)
                }
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(ColorPalette[colorScheme].foreground2)
        }
    }
    
}

// ---------------------------------------------------
// MARK: - View
// ---------------------------------------------------

struct BedTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var data: BedTimeData
    
    // -----------------------------
    // MARK: Make Input
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
                    .background(ColorPalette[colorScheme].background2)
                    .mask(Capsule())
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(ColorPalette[colorScheme].background2)
                    .frame(height: 2)
                
                makeDurationText()
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(ColorPalette[colorScheme].background2)
                    .frame(height: 2)
                
                DatePicker("Wake up time", selection: $data.endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .background(ColorPalette[colorScheme].background2)
                    .mask(Capsule())
            }
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(ColorPalette[colorScheme].foreground)
        .padding(.horizontal)
        .padding(.top)
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
    // MARK: Body
    // -----------------------------
    
    init() {
        let startDate: Date = Date(hours: 0)
        let endDate: Date = Date(hours: 6.4)
        
        data = BedTimeData(
            startTime: startDate,
            endTime: endDate)
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
    //            Spacer()
                
                VStack {
                    makeInputSection()
                    BedTimeDial(data: data)
                }
                .padding()
                .background(ColorPalette[colorScheme].background)
                .cornerRadius(20)
                .padding()
                
//                Spacer()
            }
            
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}

struct BedTimeView_Previews: PreviewProvider {
    static var previews: some View {
        BedTimeView().colorScheme(.dark)
        BedTimeView().colorScheme(.light)
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
}

extension Double {
    func fold(into range: Range<Double>) -> Double {
        if range.contains(self) { return self }
        
        let len = range.upperBound - range.lowerBound
        var val = self - range.lowerBound
        val.formTruncatingRemainder(dividingBy: len)
        val += range.lowerBound
        if val < range.lowerBound { val += len }
        
        return val
    }
    
    func fixHour() -> Double {
        return fold(into: 0..<24)
    }
}
