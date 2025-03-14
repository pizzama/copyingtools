//
//  OnboardingView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var currentPage = 0
    
    // 引导页面内容
    private let pages = [
        OnboardPage(
            title: "欢迎使用幼儿临摹工具",
            description: "这是一款专为幼儿设计的图像临摹应用，帮助孩子培养绘画技能和创造力",
            imageName: "onboarding-welcome",
            systemImageName: "hand.wave.fill",
            backgroundColor: .blue
        ),
        OnboardPage(
            title: "上传或选择图片",
            description: "从您的相册中选择图片，或使用我们提供的图库中的图片",
            imageName: "onboarding-upload",
            systemImageName: "photo.on.rectangle.angled",
            backgroundColor: .purple
        ),
        OnboardPage(
            title: "转换为素描",
            description: "将彩色图片转换为素描风格，提供多种风格选择",
            imageName: "onboarding-convert",
            systemImageName: "wand.and.stars",
            backgroundColor: .orange
        ),
        OnboardPage(
            title: "开始临摹",
            description: "对着转换后的素描进行临摹练习，享受绘画的乐趣",
            imageName: "onboarding-draw",
            systemImageName: "pencil.tip",
            backgroundColor: .green
        ),
        OnboardPage(
            title: "保存和分享",
            description: "保存您的临摹作品，与家人和朋友分享您的创作",
            imageName: "onboarding-share",
            systemImageName: "square.and.arrow.up",
            backgroundColor: .pink
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景色
            pages[currentPage].backgroundColor
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                // 页面指示器
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.primary : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // 页面内容
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(for: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // 底部按钮
                if currentPage == pages.count - 1 {
                    Button(action: {
                        isFirstLaunch = false
                    }) {
                        Text("开始使用")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                } else {
                    HStack {
                        // 跳过按钮
                        Button("跳过") {
                            isFirstLaunch = false
                        }
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // 下一页按钮
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("下一页")
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                    .frame(height: 30)
            }
        }
    }
    
    // 单页内容视图
    private func pageView(for page: OnboardPage) -> some View {
        VStack(spacing: 30) {
            // 图片（如果有）
            if let imageName = page.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .padding(.horizontal, 20)
            } else if let systemImageName = page.systemImageName {
                // 使用系统图标代替
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(page.backgroundColor)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
    }
}

// 引导页面数据模型
struct OnboardPage {
    let title: String
    let description: String
    let imageName: String?
    let systemImageName: String?
    let backgroundColor: Color
    
    init(title: String, description: String, imageName: String? = nil, systemImageName: String? = nil, backgroundColor: Color) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.systemImageName = systemImageName
        self.backgroundColor = backgroundColor
    }
}

// 预览
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isFirstLaunch: .constant(true))
    }
} 