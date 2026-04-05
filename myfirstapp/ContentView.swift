import SwiftUI
import AVFoundation

// 声明全局播放器
var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    @State private var isAnimating = false
    @State private var selectedColor: Color = .black
    @State private var isMixedMode: Bool = false
    @State private var wheelRotation: Double = 0
    @State private var fontSize: Int = 20
    
    // 用于判断方向的旧值记录
    @State private var lastRotation: Double = 0
    @State private var lastFontSize: Int = 20
    
    @State private var todayProverbs: [Proverb] = BibleData.getTodayVerses()
    
    let fontSizeOptions = [16, 18, 20, 22, 24, 26, 28]
    let sliceColors: [Color] = [.black, .red, .orange, .green, .blue, .purple, .gray]

    // 动态时间计算
    var currentTime: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: Date())
    }
    var todayDateString: String {
        let f = DateFormatter(); f.dateFormat = "MM/dd"; return f.string(from: Date())
    }
    var todayWeekdayString: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "zh_CN"); f.dateFormat = "EEEE"; return f.string(from: Date())
    }
    
    var dynamicTitle: String {
        let chapters = Set(todayProverbs.map { $0.chapter }).sorted()
        if chapters.isEmpty { return "箴言" }
        if chapters.count > 1 {
            return "箴言 第 \(chapters.first!) - \(chapters.last!) 章"
        } else {
            return "箴言 第 \(chapters.first!) 章"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 时间显示
                HStack(alignment: .center, spacing: 12) {
                    Text("2026").font(.system(size: 10, weight: .bold)).foregroundColor(.gray).frame(width: 12)
                    Text(currentTime).font(.system(size: 55, weight: .heavy, design: .rounded))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(todayDateString).font(.headline)
                        Text(todayWeekdayString).font(.caption2).foregroundColor(.secondary)
                        Label("晴", systemImage: "sun.max.fill").font(.system(size: 9)).foregroundColor(.orange)
                    }
                }
                .padding(.top, 10)

                // 2. 狮子交互区
                Image("lion")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .scaleEffect(isAnimating ? 1.03 : 1.0)
                    .shadow(radius: isAnimating ? 15 : 5)

                // 3. 经文显示区
                VStack(spacing: 12) {
                    Text(dynamicTitle).font(.headline).foregroundColor(.red)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(todayProverbs) { proverb in
                                Text("\(proverb.chapter):\(proverb.verse) \(proverb.text)")
                                    .font(.system(size: CGFloat(fontSize), design: .serif))
                                    .foregroundColor(isMixedMode ? sliceColors.dropLast().randomElement()! : selectedColor)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 350)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // 4. 控制面板
                HStack(spacing: 0) {
                    // 转盘逻辑：在组件内部处理方向判断并传出音频名
                    ColorWheelView(selectedColor: $selectedColor, isMixedMode: $isMixedMode, wheelRotation: $wheelRotation, lastRotation: $lastRotation, sliceColors: sliceColors) { soundName in
                        playSound(named: soundName)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 5) {
                        Text("字号").font(.caption2).foregroundColor(.secondary)
                        Picker("", selection: $fontSize) {
                            ForEach(fontSizeOptions, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.wheel).frame(width: 80, height: 80).clipped()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 40)
            }
        }
        // 字号改变时的音频逻辑
        .onChange(of: fontSize) { oldValue, newValue in
            if newValue > oldValue {
                playSound(named: "lion_sound") // 变大：狮子吼
            } else {
                playSound(named: "cat_sound")  // 变小：猫叫
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    func playSound(named soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch { print("声音播放失败") }
    }
}

struct ColorWheelView: View {
    @Binding var selectedColor: Color
    @Binding var isMixedMode: Bool
    @Binding var wheelRotation: Double
    @Binding var lastRotation: Double
    let sliceColors: [Color]
    var onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 5) {
            Text("颜色").font(.caption2).foregroundColor(.secondary)
            ZStack {
                ForEach(0..<7) { i in
                    SectorShape(startAngle: Angle(degrees: Double(i) * 360/7), endAngle: Angle(degrees: Double(i+1) * 360/7))
                        .fill(i == 6 ? AnyShapeStyle(AngularGradient(colors: [.red, .blue, .green, .red], center: .center)) : AnyShapeStyle(sliceColors[i]))
                        .onTapGesture {
                            let targetRotation = -Double(i) * 360/7 - 180/7
                            
                            // 判断旋转方向 (顺时针旋转角度会减小，逆时针增大)
                            // 在转盘交互中，我们根据目标角度与当前角度的差值来判断
                            let soundEffect = targetRotation < wheelRotation ? "lion_sound" : "cat_sound"
                            
                            withAnimation(.spring()) {
                                wheelRotation = targetRotation
                                if i < 6 { isMixedMode = false; selectedColor = sliceColors[i] }
                                else { isMixedMode = true }
                            }
                            onSelect(soundEffect)
                        }
                }
            }
            .rotationEffect(.degrees(wheelRotation)).frame(width: 80, height: 80)
        }
    }
}

struct SectorShape: Shape {
    var startAngle: Angle; var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var path = Path(); let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width/2, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath(); return path
    }
}
