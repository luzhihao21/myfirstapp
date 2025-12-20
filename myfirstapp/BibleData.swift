import Foundation

struct Proverb: Identifiable {
    let id = UUID()
    let chapter: Int
    let verse: Int
    let text: String
}

struct BibleData {
    // 1. 获取今天需要显示的章节数组
    static func getTodayChapterNumbers() -> [Int] {
        let calendar = Calendar.current
        let now = Date()
        let day = calendar.component(.day, from: now)
        
        // 获取本月天数范围
        let range = calendar.range(of: .day, in: .month, for: now)
        let lastDayOfMonth = range?.count ?? 31
        
        // 如果是本月最后一天且不满31号，则返回从今天到31的所有章节
        if day == lastDayOfMonth && day < 31 {
            return Array(day...31)
        } else {
            return [day]
        }
    }

    // 2. 从文本文件读取并筛选对应的经文
    static func getTodayVerses() -> [Proverb] {
        let chapterNumbers = getTodayChapterNumbers()
        var results: [Proverb] = []
        
        guard let path = Bundle.main.path(forResource: "Proverbs", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return [Proverb(chapter: 0, verse: 0, text: "经文文件 Proverbs.txt 丢失")]
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            // 假设格式为 "章:节 经文"
            let parts = trimmedLine.components(separatedBy: " ")
            if parts.count >= 2 {
                let ref = parts[0].components(separatedBy: ":")
                if ref.count == 2,
                   let ch = Int(ref[0]),
                   let ve = Int(ref[1]) {
                    
                    // 如果该行章节在我们需要显示的列表中
                    if chapterNumbers.contains(ch) {
                        let text = parts[1...].joined(separator: " ")
                        results.append(Proverb(chapter: ch, verse: ve, text: text))
                    }
                }
            }
        }
        return results
    }
}
