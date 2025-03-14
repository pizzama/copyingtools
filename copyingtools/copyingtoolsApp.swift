//
//  copyingtoolsApp.swift
//  copyingtools
//
//  Created by pizzaman on 2025/3/14.
//

import SwiftUI

@main
struct copyingtoolsApp: App {
    // 使用StateObject创建全局应用状态
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // 使用NavigationView作为应用主导航容器
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(appState)
        }
    }
}

// 全局应用状态类
class AppState: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var userWorks: [ArtWork] = []
    @Published var isFirstLaunch: Bool = UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil
    
    init() {
        // 如果是首次启动，记录状态
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        
        // 这里可以添加其他初始化逻辑，如加载用户数据、作品等
        loadUserData()
    }
    
    private func loadUserData() {
        // 模拟加载用户数据
        self.currentUser = User(name: "小画家", avatarName: "child.avatar")
        
        // 模拟加载用户作品
        self.userWorks = [
            ArtWork(title: "小猫", type: .animal, createdAt: Date(), imageUrl: "sample_cat"),
            ArtWork(title: "彩虹", type: .other, createdAt: Date().addingTimeInterval(-86400), imageUrl: "sample_rainbow")
        ]
    }
}
