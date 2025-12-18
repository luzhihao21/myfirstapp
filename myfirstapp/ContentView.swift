import SwiftUI
import AVFoundation

var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    @State var textColor = Color.black
    // 1. 控制呼吸动画的状态
    @State var isAnimating = false
    // 2. 控制播放按钮淡淡出现（透明度）的状态
    @State var buttonOpacity = 0.3
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 使用 ZStack 让按钮盖在图片上
            // --- 从这里开始替换 ---
                        ZStack(alignment: .bottomTrailing) { // 修改点1：改为右下角
                            
                            // 底层：狮子图片
                            Image("lion")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 280)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .scaleEffect(isAnimating ? 1.03 : 1.0)
                                .shadow(radius: isAnimating ? 15 : 5)
                            
                            // 顶层：播放按钮图标
                            Image(systemName: "play.fill")
                                .font(.system(size: 20)) // 修改点2：图标调小
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.3)) // 修改点3：背景变淡
                                .clipShape(Circle())
                                .opacity(isAnimating ? 0.3 : 0.05)    // 修改点4：透明度大幅降低
                                .offset(x: -15, y: -15)              // 修改点5：向内偏移
                        }
                        .onTapGesture {
                                    playSound()
                                }
                        // --- 替换到这里结束 ---
            .onAppear {
                // 3. 当页面出现时，启动循环动画
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                    buttonOpacity = 0.8 // 按钮从 0.3 变到 0.8，产生呼吸感
                }
            }
            
            Text("我的狮子大王")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            Button("点我变颜色") {
                textColor = (textColor == .black) ? .orange : .black
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    func playSound() {
        if let path = Bundle.main.path(forResource: "lion_sound", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("音频播放失败")
            }
        }
    }
}
