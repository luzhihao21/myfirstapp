# 每日箴言 (Daily Proverbs) - iOS App

## 🌟 概要 / Overview / 概要
**[JP]** 聖書の「箴言」を毎日一章ずつ提供し、心に平穏をもたらすライフスタイルアプリです。直感的なUIと遊び心のある音效インタラクションを特徴としています。
**[CN]** 这是一款每天提供一章圣经《箴言》的励志应用，旨在为用户带来心灵的平静。特点是拥有直观的 UI 以及有趣的音效交互。
**[EN]** A lifestyle app that provides one chapter of Biblical Proverbs daily. It features an intuitive UI and playful audio interactions.

---

## 🛠 技术栈 / Tech Stack / 技術スタック
- **Language:** Swift 5.9+
- **Framework:** SwiftUI
- **Audio:** AVFoundation (AVAudioPlayer)
- **Architecture:** MVVM (State & Binding)
- **Tools:** Xcode, Git, AI-Assisted Development (ChatGPT/Gemini)

---

## ✨ 核心功能 / Key Features / 主な機能
### 1. 动态音效反馈 (Dynamic Audio Feedback)
- **[JP]** 操作方向に応じた音效変化。カラーホイールの回転方向やフォントサイズの増減により、ライオンの咆哮や猫の鳴き声が再生されます。
- **[CN]** 根据操作方向触发不同音效。调整色盘方向或改变字号大小时，会触发狮子吼或猫叫声。
- **[EN]** Context-aware audio feedback. Lion roars or cat meows are triggered based on the direction of color wheel rotation or font size adjustment.

### 2. 视觉自定义 (Visual Customization)
- **[JP]** SwiftUIのState管理を活用したリアルタイムな文字色とサイズの変更。
- **[CN]** 利用 SwiftUI 的状态管理实现文字颜色和字号的实时更新。
- **[EN]** Real-time text color and size customization powered by SwiftUI State management.

---

## 📖 逻辑亮点 / Logic Highlights / 実装のポイント
- **Direction Detection:** 实现了一个对比逻辑，通过记录 `oldValue` 与 `newValue` 来感知用户的操作趋势（变大/变小，顺时针/逆时针），从而触发差异化音效。
- **Interactive UI:** 使用了自定义的 `SectorShape` 构建交互式颜色转盘。
## アプリのスクリーンショット  👇
https://github.com/luzhihao21/myfirstapp/issues/1#issue-4221826337
## 動画 👇
https://youtube.com/shorts/WecKpyPaeEw?si=DcPze_0BTX4p6EIn
