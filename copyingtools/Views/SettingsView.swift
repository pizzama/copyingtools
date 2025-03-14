//
//  SettingsView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    // 用户设置的临时副本
    @State private var userName: String = ""
    @State private var soundEnabled: Bool = true
    @State private var autoSaveEnabled: Bool = true
    @State private var backgroundMusicEnabled: Bool = false
    @State private var selectedFontSize: FontSize = .medium
    
    // 状态变量
    @State private var showingResetAlert = false
    @State private var showingLogoutAlert = false
    @State private var showingEditNameSheet = false
    @State private var newUserName: String = ""
    @State private var showingSavedAlert = false
    
    // 环境变量
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 个人资料部分
                profileSection
                
                // 应用设置部分
                appSettingsSection
                
                // 高级设置部分
                advancedSettingsSection
                
                // 关于部分
                aboutSection
                
                // 版本信息
                Text("版本 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 30)
            }
            .padding()
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("保存") {
            saveSettings()
        })
        .onAppear {
            // 加载当前设置
            loadCurrentSettings()
        }
        .alert(isPresented: $showingSavedAlert) {
            Alert(
                title: Text("设置已保存"),
                message: Text("您的设置已成功更新"),
                dismissButton: .default(Text("确定"))
            )
        }
        .sheet(isPresented: $showingEditNameSheet) {
            editNameView
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("重置应用"),
                message: Text("这将删除所有作品和设置。此操作无法撤销。"),
                primaryButton: .destructive(Text("重置")) {
                    resetApp()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // 个人资料部分
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("个人资料")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                // 头像
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
                    .padding(8)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("小小艺术家")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    newUserName = userName
                    showingEditNameSheet = true
                }) {
                    Text("编辑")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // 应用设置部分
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("应用设置")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                // 声音提示开关
                SettingToggleRow(
                    title: "声音提示",
                    description: "操作时播放音效",
                    isOn: $soundEnabled,
                    iconName: "speaker.wave.2.fill"
                )
                
                Divider()
                
                // 自动保存开关
                SettingToggleRow(
                    title: "自动保存",
                    description: "自动保存处理后的图片",
                    isOn: $autoSaveEnabled,
                    iconName: "arrow.down.doc.fill"
                )
                
                Divider()
                
                // 背景音乐开关
                SettingToggleRow(
                    title: "背景音乐",
                    description: "播放轻柔的背景音乐",
                    isOn: $backgroundMusicEnabled,
                    iconName: "music.note"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // 字体大小选择器
            VStack(alignment: .leading, spacing: 10) {
                Text("界面字体大小")
                    .font(.headline)
                    .padding(.top, 5)
                
                Picker("字体大小", selection: $selectedFontSize) {
                    ForEach(FontSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.top, 5)
        }
    }
    
    // 高级设置部分
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("高级设置")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                // 清除缓存
                Button(action: {
                    StorageService.shared.cleanupTempFiles()
                }) {
                    SettingRow(
                        title: "清除缓存",
                        description: "删除临时文件和缓存",
                        iconName: "trash",
                        iconColor: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                
                // 重置应用
                Button(action: {
                    showingResetAlert = true
                }) {
                    SettingRow(
                        title: "重置应用",
                        description: "清除所有数据和设置",
                        iconName: "arrow.counterclockwise",
                        iconColor: .red
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // 关于部分
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("关于")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                // 隐私政策
                NavigationLink(destination: PrivacyPolicyView()) {
                    SettingRow(
                        title: "隐私政策",
                        description: "了解我们如何保护您的隐私",
                        iconName: "hand.raised.fill",
                        iconColor: .blue
                    )
                }
                
                Divider()
                
                // 使用条款
                NavigationLink(destination: TermsOfServiceView()) {
                    SettingRow(
                        title: "使用条款",
                        description: "查看应用使用条款",
                        iconName: "doc.text.fill",
                        iconColor: .blue
                    )
                }
                
                Divider()
                
                // 联系我们
                Button(action: {
                    // 打开邮件或其他联系方式
                }) {
                    SettingRow(
                        title: "联系我们",
                        description: "有问题或建议请联系我们",
                        iconName: "envelope.fill",
                        iconColor: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // 编辑名称视图
    private var editNameView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("编辑用户名")
                    .font(.headline)
                    .padding(.top, 20)
                
                TextField("用户名", text: $newUserName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("取消") {
                    showingEditNameSheet = false
                },
                trailing: Button("保存") {
                    userName = newUserName
                    showingEditNameSheet = false
                }
            )
        }
    }
    
    // 加载当前设置
    private func loadCurrentSettings() {
        if let user = appState.currentUser {
            userName = user.name
            soundEnabled = user.settings.soundEnabled
            autoSaveEnabled = user.settings.autoSaveEnabled
            backgroundMusicEnabled = user.settings.backgroundMusicEnabled
            selectedFontSize = user.settings.fontSize
        }
    }
    
    // 保存设置
    private func saveSettings() {
        guard var user = appState.currentUser else { return }
        
        // 更新用户信息
        user.name = userName
        user.settings.soundEnabled = soundEnabled
        user.settings.autoSaveEnabled = autoSaveEnabled
        user.settings.backgroundMusicEnabled = backgroundMusicEnabled
        user.settings.fontSize = selectedFontSize
        
        // 更新应用状态
        appState.currentUser = user
        
        // 持久化保存
        StorageService.shared.saveUser(user)
        
        // 显示保存成功
        showingSavedAlert = true
    }
    
    // 重置应用
    private func resetApp() {
        // 清除作品
        appState.userWorks.removeAll()
        StorageService.shared.saveArtWorks([])
        
        // 清除用户设置（保留用户名）
        if var user = appState.currentUser {
            user.settings = UserSettings()
            appState.currentUser = user
            StorageService.shared.saveUser(user)
        }
        
        // 重新加载设置
        loadCurrentSettings()
        
        // 清除缓存
        StorageService.shared.cleanupTempFiles()
    }
}

// 设置项行
struct SettingRow: View {
    let title: String
    let description: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            // 图标
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
            
            // 文本
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 箭头
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// 带开关的设置项行
struct SettingToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let iconName: String
    
    var body: some View {
        HStack {
            // 图标
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(isOn ? .accentColor : .gray)
                .frame(width: 36, height: 36)
            
            // 文本
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 开关
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// 隐私政策视图（简化）
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("隐私政策")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("最后更新: 2025年3月14日")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("我们非常重视您的隐私。本隐私政策说明了我们收集、使用和保护您的个人信息的方式。")
                    .padding(.top, 10)
                
                Text("信息收集")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("我们只收集必要的信息来提供服务，如用户名和创作的作品数据。我们不会收集未经您同意的个人敏感信息。")
                
                Text("信息使用")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("我们使用收集的信息来提供、维护和改进我们的服务。您的作品数据仅存储在本地设备上，除非您主动选择分享。")
                
                Text("信息保护")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("我们采取适当的安全措施来保护您的信息不被未经授权的访问或披露。")
                
                // 更多隐私政策内容...
            }
            .padding()
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 使用条款视图（简化）
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("使用条款")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("最后更新: 2025年3月14日")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("欢迎使用幼儿临摹工具应用。通过使用本应用，您同意以下条款和条件。")
                    .padding(.top, 10)
                
                Text("使用许可")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("我们授予您下载和使用本应用的非独占性许可，仅供个人和非商业用途。")
                
                Text("内容所有权")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("应用中的默认图库内容归我们所有。您创建的作品归您所有，但我们可能会匿名使用这些作品来改进我们的服务。")
                
                Text("禁止行为")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("您不得复制、修改、分发或销售本应用的任何部分，也不得尝试逆向工程或破解本应用。")
                
                // 更多使用条款内容...
            }
            .padding()
        }
        .navigationTitle("使用条款")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 预览
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .environmentObject(AppState())
    }
} 