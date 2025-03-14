//
//  ContentView.swift
//  copyingtools
//
//  Created by pizzaman on 2025/3/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            // 主应用界面 - 用户已登录或不是首次启动
            if !appState.isFirstLaunch {
                NavigationView {
                    HomeView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .accentColor(.purple) // 应用主题色
            } else {
                // 首次启动 - 显示引导页
                OnboardingView(isFirstLaunch: $appState.isFirstLaunch)
            }
        }
        .onAppear {
            // 如果是首次启动，创建默认用户
            if appState.isFirstLaunch && appState.currentUser == nil {
                appState.currentUser = User(name: "小画家", avatarName: "child.avatar")
                StorageService.shared.saveUser(appState.currentUser!)
            }
        }
    }
}

// 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
