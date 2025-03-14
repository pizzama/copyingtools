//
//  User.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import Foundation

struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var avatarName: String
    var createdAt: Date = Date()
    var lastActiveAt: Date = Date()
    var settings: UserSettings = UserSettings()
    
    // 用户完成的作品数量
    var completedWorks: Int = 0
    
    // 成就记录
    var achievements: [Achievement] = []
}

// 用户设置
struct UserSettings: Codable {
    // 声音提示开关
    var soundEnabled: Bool = true
    
    // 自动保存开关
    var autoSaveEnabled: Bool = true
    
    // 背景音乐开关
    var backgroundMusicEnabled: Bool = false
    
    // 界面字体大小
    var fontSize: FontSize = .medium
}

// 字体大小选项
enum FontSize: String, Codable, CaseIterable {
    case small = "小"
    case medium = "中"
    case large = "大"
}

// 用户成就
struct Achievement: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var iconName: String
    var achievedAt: Date
} 