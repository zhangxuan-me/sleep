//
//  ContentView.swift
//  sleep
//
//  Created by xuan on 2024/11/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sleepStore = SleepStore()
    
    var body: some View {
        TabView {
            HomeView(sleepStore: sleepStore)
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
            
            StatisticsView(sleepStore: sleepStore)
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .tint(.blue)
    }
}

// 数据统计页面
struct StatisticsView: View {
    @ObservedObject var sleepStore: SleepStore
    @State private var selectedTimeRange = 1 // 默认显示月视图
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 时间范围选择器
                Picker("时间范围", selection: $selectedTimeRange) {
                    Text("周").tag(0)
                    Text("月").tag(1)
                    Text("年").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 根据选择显示不同的统计视图
                switch selectedTimeRange {
                case 0:
                    WeekCalendarView(sleepStore: sleepStore)
                case 1:
                    MonthCalendarView(sleepStore: sleepStore)
                default:
                    YearCalendarView(sleepStore: sleepStore)
                }
            }
            .navigationTitle("睡眠统计")
        }
    }
}

// 周日历视图
struct WeekCalendarView: View {
    @ObservedObject var sleepStore: SleepStore
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // 日期导航
            HStack {
                Button(action: { moveWeek(-1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { moveWeek(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // 周视图
            VStack(spacing: 10) {
                // 星期行
                HStack {
                    ForEach(weekDaySymbols, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 日期行
                HStack {
                    ForEach(weekDates, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 20))
                            
                            // 这里可以添加睡眠数据指示器
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 6, height: 6)
                                .opacity(hasSleepRecord(for: date) ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            isToday(date) ? Color.blue.opacity(0.1) : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var weekDaySymbols: [String] { ["日", "一", "二", "三", "四", "五", "六"] }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: selectedDate)
    }
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    private func moveWeek(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private func hasSleepRecord(for date: Date) -> Bool {
        // 这里实现检查是否有睡眠记录的逻辑
        return false
    }
}

// 月日历视图
struct MonthCalendarView: View {
    @ObservedObject var sleepStore: SleepStore
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // 日期导航
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // 使用更大的单个月份视图
            MonthGridView(selectedDate: selectedDate, isYearView: false)
                .padding(.horizontal, 8)
            
            Spacer()
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: selectedDate)
    }
    
    private func moveMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// 新增月份网格视图组件
struct MonthGridView: View {
    let selectedDate: Date
    let isYearView: Bool // 添加标识符来区分年视图和月视图
    
    init(selectedDate: Date, isYearView: Bool = false) {
        self.selectedDate = selectedDate
        self.isYearView = isYearView
    }
    
    var body: some View {
        VStack(spacing: isYearView ? 2 : 4) {
            // 如果是年视图显示月份标题
            if isYearView {
                Text("\(Calendar.current.component(.month, from: selectedDate))月")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 星期行
            HStack(spacing: 0) {
                ForEach(weekDaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: isYearView ? 8 : 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日期网格
            ForEach(monthWeeks, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { date in
                        if let date = date {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: isYearView ? 8 : 14))
                                .frame(maxWidth: .infinity)
                                .frame(height: isYearView ? 15 : 35)
                                .background(
                                    isToday(date) ? Color.blue.opacity(0.1) : Color.clear
                                )
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: isYearView ? 15 : 35)
                        }
                    }
                }
            }
        }
        .padding(isYearView ? 4 : 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var weekDaySymbols: [String] { ["日", "一", "二", "三", "四", "五", "六"] }
    
    private var monthWeeks: [[Date?]] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        
        var dates: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: calendar.component(.month, from: selectedDate), day: day))!) {
                dates.append(date)
            }
        }
        
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        
        return stride(from: 0, to: dates.count, by: 7).map {
            Array(dates[$0..<min($0 + 7, dates.count)])
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
}

// 年日历视图
struct YearCalendarView: View {
    @ObservedObject var sleepStore: SleepStore
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // 年份导航
            HStack {
                Button(action: { moveYear(-1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("\(Calendar.current.component(.year, from: selectedDate))年")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { moveYear(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // 月份网格，每行2个月
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(1...12, id: \.self) { month in
                        MonthGridView(selectedDate: dateForMonth(month), isYearView: true)
                            .frame(height: 150) // 固定高度
                            .frame(maxWidth: .infinity) // 确保宽度一致
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func moveYear(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .year, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func dateForMonth(_ month: Int) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let components = DateComponents(year: year, month: month)
        return calendar.date(from: components)!
    }
}

// 设置页面
struct SettingsView: View {
    @State private var language = "简体中文"
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                // 语言设置
                Section(header: Text("语言设置")) {
                    NavigationLink(destination: LanguageSettingsView()) {
                        Label("语言", systemImage: "globe")
                    }
                }
                
                // 主题设置
                Section(header: Text("主题设置")) {
                    NavigationLink(destination: ThemeSettingsView()) {
                        Label("主题", systemImage: "paintbrush.fill")
                    }
                }
                
                // 通知设置
                Section(header: Text("通知设置")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("通知", systemImage: "bell.fill")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

// 语言设置视图
struct LanguageSettingsView: View {
    var body: some View {
        List {
            Text("语言设置选项")
        }
        .navigationTitle("语言")
    }
}

// 主题设置视图
struct ThemeSettingsView: View {
    var body: some View {
        List {
            Text("主题设置选项")
        }
        .navigationTitle("主题")
    }
}

// 通知设置视图
struct NotificationSettingsView: View {
    var body: some View {
        List {
            Text("通知设置选项")
        }
        .navigationTitle("通知")
    }
}

// 主页（记录页面）
struct HomeView: View {
    @ObservedObject var sleepStore: SleepStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 欢迎卡片
                    WelcomeCard()
                    
                    // 昨夜睡眠情况卡片
                    LastNightSleepCard(sleepStore: sleepStore)
                    
                    // 本周睡眠追踪卡片
                    WeeklyTrackingCard(sleepStore: sleepStore)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("睡眠记录")
                            .font(.system(size: 16, weight: .medium))
                        Text(formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: today)
    }
}

// 欢迎卡片组件
struct WelcomeCard: View {
    var body: some View {
        VStack {
            // 欢迎卡片的具体实现
            Text("欢迎卡片")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

// 昨夜睡眠卡片组件
struct LastNightSleepCard: View {
    @ObservedObject var sleepStore: SleepStore
    
    var body: some View {
        VStack {
            // 夜睡眠数据展示
            Text("昨夜睡眠情况")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
}

// 周追踪卡片组
struct WeeklyTrackingCard: View {
    @ObservedObject var sleepStore: SleepStore
    
    var body: some View {
        VStack {
            // 本周睡眠追踪数据
            Text("本周睡眠追踪")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(15)
    }
}

struct HistoryView: View {
    @ObservedObject var sleepStore: SleepStore
    
    var body: some View {
        NavigationView {
            List(sleepStore.sleepRecords) { record in
                VStack(alignment: .leading) {
                    Text("睡眠时间: \(record.sleepTime.formatted())")
                    if let wakeTime = record.wakeTime {
                        Text("起床时间: \(wakeTime.formatted())")
                        if let duration = record.duration {
                            Text("持续时间: \(formatDuration(duration))")
                        }
                    }
                    if !record.note.isEmpty {
                        Text("备注: \(record.note)")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("睡眠历史")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%d小时%d分钟", hours, minutes)
    }
}

#Preview {
    ContentView()
}
