import SwiftUI
import AVFoundation

var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    @State private var isAnimating = false
    @State private var textColor = Color.black // 用于控制变色的变量
    
    // --- 1. 获取动态时间数据 ---
    var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: Date())
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 显示小时和分钟
        return formatter.string(from: Date())
    }
    
    var currentDateAndWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 EEEE"
        return formatter.string(from: Date())
    }
    
    // 获取当天的日期数字作为章节
    var dayNumber: Int {
        Calendar.current.component(.day, from: Date())
    }
    
    // --- 2. 模拟箴言章节数据 ---
    // 实际开发中这里可以填入完整的经文列表
    var chapterVerses: [String] {
        if dayNumber == 18 {
            return [
                "与众寡合的，独自寻求心愿，并恼恨一切真智慧。",
                "愚昧人不喜爱明哲，只喜爱显露心意。",
                "恶人来，羞耻也来；强暴到，辱骂也到。",
                "人口中的言语如同深水；智慧的泉源好像涌流的河水。"
            ]
        } else {
            return ["谨守训诲的，乃在生命的道上。", "听从责备的，却得着知识。"]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                
                // --- 醒目的三行时间设计 ---
                VStack(spacing: 5) {
                    Text(currentYear)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                    
                    Text(currentTime)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(currentDateAndWeek)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                
                // --- 狮子交互区 ---
                ZStack(alignment: .bottomTrailing) {
                    Image("lion")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .scaleEffect(isAnimating ? 1.03 : 1.0)
                        .shadow(radius: isAnimating ? 15 : 5)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                        .opacity(isAnimating ? 0.4 : 0.1)
                        .offset(x: -15, y: -15)
                }
                .onTapGesture { playSound() }
                
                // --- 箴言列表区 (参考你的手绘图) ---
                VStack(spacing: 20) {
                    // 标题：箴言第xx章 (数字为红色)
                    HStack(spacing: 0) {
                        Text("箴言 第 ")
                        Text("\(dayNumber)")
                            .foregroundColor(.red) // 数字变红
                            .font(.title2)
                            .bold()
                        Text(" 章")
                    }
                    .font(.title3)
                    .padding(.bottom, 10)
                    
                    // 列表内容：18 : 1 XXX
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(0..<chapterVerses.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 15) {
                                // 左侧数字标识
                                Text("\(dayNumber) : \(index + 1)")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.orange)
                                    .frame(width: 60, alignment: .leading)
                                
                                // 右侧经文文字
                                Text(chapterVerses[index])
                                    .font(.system(size: 18, design: .serif))
                                    .foregroundColor(textColor) // 绑定变色变量
                                    .lineSpacing(5)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                // --- 修复后的变色按钮 ---
                Button(action: {
                    // 按钮点击逻辑：在黑色和橙色间切换
                    if textColor == .black {
                        textColor = .orange
                    } else {
                        textColor = .black
                    }
                }) {
                    Text("更改文字颜色")
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
}
