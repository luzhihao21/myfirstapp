import SwiftUI
import AVFoundation

// 全局音频播放器
var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    // --- 状态变量 ---
    @State private var isAnimating = false
    @State private var selectedColor: Color = .black
    @State private var isMixedMode: Bool = false
    @State private var wheelRotation: Double = 0
    @State private var fontSize: Int = 20
    
    let fontSizeOptions = [16, 18, 20, 22, 24, 26, 28]
    let sliceColors: [Color] = [.black, .red, .orange, .green, .blue, .purple, .gray]

    var currentTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 时间区
                HStack(alignment: .center, spacing: 12) {
                    Text("2025").font(.system(size: 10, weight: .bold)).foregroundColor(.gray).frame(width: 12)
                    Text(currentTime).font(.system(size: 55, weight: .heavy, design: .rounded))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("12/18").font(.headline)
                        Text("星期四").font(.caption2).foregroundColor(.secondary)
                        Label("多云", systemImage: "cloud.sun.fill").font(.system(size: 9)).foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)

                // 2. 狮子交互
                ZStack(alignment: .bottomTrailing) {
                    Image("lion")
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 210)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .scaleEffect(isAnimating ? 1.03 : 1.0)
                        .shadow(radius: isAnimating ? 15 : 5)
                    Image(systemName: "play.fill").font(.system(size: 16)).foregroundColor(.white).padding(6)
                        .background(Color.black.opacity(0.3)).clipShape(Circle())
                        .opacity(isAnimating ? 0.4 : 0.1).offset(x: -12, y: -12)
                }
                .onTapGesture { playSound() }

                // 3. 箴言显示区
                VStack(spacing: 12) {
                    HStack {
                        Text("箴言 第").font(.subheadline)
                        Text("18").foregroundColor(.red).bold()
                        Text("章").font(.subheadline)
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(0..<chapterVerses.count, id: \.self) { i in
                            Text(chapterVerses[i])
                                .font(.system(size: CGFloat(fontSize), design: .serif))
                                .foregroundColor(isMixedMode ? sliceColors.dropLast().randomElement()! : selectedColor)
                        }
                    }
                    .padding().background(Color.gray.opacity(0.05)).cornerRadius(12)
                }
                .padding(.horizontal)

                // 4. 控制面板 (横排布局)
                HStack(spacing: 0) {
                    // 左侧：西瓜颜色转盘 (已独立封装)
                    ColorWheelView(selectedColor: $selectedColor, isMixedMode: $isMixedMode, wheelRotation: $wheelRotation, sliceColors: sliceColors)
                        .frame(maxWidth: .infinity)

                    // 右侧：字号滚轮
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
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    func playSound() {
        guard let path = Bundle.main.path(forResource: "lion_sound", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch { print("播放失败") }
    }
    
    var chapterVerses: [String] {
        return ["18:1 与众寡合的，独自寻求心愿。", "18:2 愚昧人不喜爱明哲。"]
    }
}

// --- 拆分出来的组件 1: 颜色转盘 ---
struct ColorWheelView: View {
    @Binding var selectedColor: Color
    @Binding var isMixedMode: Bool
    @Binding var wheelRotation: Double
    let sliceColors: [Color]

    var body: some View {
        VStack(spacing: 5) {
            Text("颜色").font(.caption2).foregroundColor(.secondary)
            ZStack {
                ForEach(0..<7) { i in
                    SectorShape(startAngle: Angle(degrees: Double(i) * 360/7),
                                endAngle: Angle(degrees: Double(i+1) * 360/7))
                        .fill(i == 6 ? AnyShapeStyle(AngularGradient(colors: [.red, .blue, .green, .red], center: .center)) : AnyShapeStyle(sliceColors[i]))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                wheelRotation = -Double(i) * 360/7 - 180/7
                                if i < 6 { isMixedMode = false; selectedColor = sliceColors[i] }
                                else { isMixedMode = true }
                            }
                        }
                }
                if isMixedMode {
                    Text("混").font(.system(size: 10)).bold().foregroundColor(.white)
                        .offset(y: -25).rotationEffect(.degrees(-wheelRotation))
                }
            }
            .rotationEffect(.degrees(wheelRotation))
            .frame(width: 80, height: 80)
        }
    }
}

// --- 拆分出来的组件 2: 扇形工具 ---
struct SectorShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width/2, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}
