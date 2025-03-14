//
//  HomeView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingUploadOptions = false
    
    private let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 顶部欢迎信息
                welcomeSection
                
                // 开始临摹按钮
                startSketchingButton
                
                // 最近临摹作品
                recentWorksSection
                
                // 默认图库部分
                defaultGallerySection
            }
            .padding()
        }
        .navigationTitle("幼儿临摹工具")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                }
            }
        }
        .actionSheet(isPresented: $showingUploadOptions) {
            ActionSheet(
                title: Text("选择图片来源"),
                buttons: [
                    .default(Text("拍摄照片")) {
                        // 打开相机
                    },
                    .default(Text("从相册选择")) {
                        // 打开相册
                    },
                    .default(Text("从图库选择")) {
                        // 导航到默认图库
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
    }
    
    // 欢迎部分
    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("你好，\(appState.currentUser?.name ?? "小画家")！")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("今天想画什么呢？")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 用户头像
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.accentColor)
                .padding(5)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    // 开始临摹按钮
    private var startSketchingButton: some View {
        Button(action: {
            showingUploadOptions = true
        }) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("开始临摹")
                        .font(.headline)
                    
                    Text("上传图片或从图库选择图片进行临摹")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 最近临摹作品部分
    private var recentWorksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("最近临摹")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: GalleryView()) {
                    Text("查看更多")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            if appState.userWorks.isEmpty {
                Text("还没有临摹作品")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(appState.userWorks.prefix(5)) { work in
                            NavigationLink(destination: ArtworkDetailView(artwork: work)) {
                                RecentWorkCard(work: work)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    // 默认图库部分
    private var defaultGallerySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("默认图库")
                .font(.headline)
            
            LazyVGrid(columns: gridItems, spacing: 15) {
                GalleryCategoryCard(title: "动物", iconName: "hare.fill", count: 12)
                GalleryCategoryCard(title: "植物", iconName: "leaf.fill", count: 8)
                GalleryCategoryCard(title: "交通工具", iconName: "car.fill", count: 10)
                GalleryCategoryCard(title: "卡通人物", iconName: "person.fill", count: 15)
            }
        }
    }
}

// 最近作品卡片
struct RecentWorkCard: View {
    let work: ArtWork
    
    var body: some View {
        VStack(alignment: .leading) {
            // 图片占位符，实际应用中这里应该加载实际图片
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 120)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: work.type.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            Text(work.title)
                .font(.subheadline)
                .lineLimit(1)
            
            Text(formattedDate(work.createdAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// 图库分类卡片
struct GalleryCategoryCard: View {
    let title: String
    let iconName: String
    let count: Int
    
    var body: some View {
        NavigationLink(destination: CategoryGalleryView(category: title)) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    
                    Text("\(count)个图片")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 预览
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .environmentObject(AppState())
    }
} 