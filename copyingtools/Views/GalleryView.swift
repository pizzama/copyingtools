//
//  GalleryView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter: ArtWorkType?
    @State private var isEditMode = false
    @State private var selectedWorks = Set<UUID>()
    
    private var filteredWorks: [ArtWork] {
        var works = appState.userWorks
        
        // 应用搜索过滤
        if !searchText.isEmpty {
            works = works.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 应用类型过滤
        if let filter = selectedFilter {
            works = works.filter { $0.type == filter }
        }
        
        return works
    }
    
    // 根据当前数据生成Grid布局
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            // 搜索栏
            searchBar
            
            // 类型筛选
            filterBar
            
            if filteredWorks.isEmpty {
                // 空状态
                emptyStateView
            } else {
                // 作品网格
                artworkGrid
            }
        }
        .navigationTitle("我的作品集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        isEditMode.toggle()
                        if !isEditMode {
                            selectedWorks.removeAll()
                        }
                    }
                }) {
                    Text(isEditMode ? "完成" : "编辑")
                }
            }
        }
        .overlay(
            // 编辑模式下的底部工具栏
            VStack {
                Spacer()
                if isEditMode && !selectedWorks.isEmpty {
                    editToolbar
                }
            }
        )
    }
    
    // 搜索栏
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索作品", text: $searchText)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // 类型筛选栏
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全部类型按钮
                FilterButton(
                    title: "全部",
                    isSelected: selectedFilter == nil,
                    action: { selectedFilter = nil }
                )
                
                // 各类型过滤按钮
                ForEach(ArtWorkType.allCases, id: \.self) { type in
                    FilterButton(
                        title: type.rawValue,
                        isSelected: selectedFilter == type,
                        action: { selectedFilter = type }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // 作品网格
    private var artworkGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredWorks) { artwork in
                    ArtworkGridItem(
                        artwork: artwork,
                        isEditMode: isEditMode,
                        isSelected: selectedWorks.contains(artwork.id),
                        onSelect: { toggleSelection(of: artwork) }
                    )
                }
            }
            .padding()
        }
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("还没有作品")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("您可以通过上传图片并转换为素描来创建作品")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            NavigationLink(destination: UploadView()) {
                Text("创建作品")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 编辑工具栏
    private var editToolbar: some View {
        HStack(spacing: 20) {
            // 删除按钮
            Button(action: deleteSelectedWorks) {
                VStack {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("删除")
                        .font(.caption)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
            
            // 导出按钮
            Button(action: exportSelectedWorks) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    Text("导出")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
            }
            
            // 分享按钮
            Button(action: shareSelectedWorks) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    Text("分享")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -3)
        .padding(.horizontal)
        .transition(.move(edge: .bottom))
    }
    
    // MARK: - 功能方法
    
    // 切换选择状态
    private func toggleSelection(of artwork: ArtWork) {
        if selectedWorks.contains(artwork.id) {
            selectedWorks.remove(artwork.id)
        } else {
            selectedWorks.insert(artwork.id)
        }
    }
    
    // 删除选中作品
    private func deleteSelectedWorks() {
        // 从作品列表中过滤掉选中的作品
        appState.userWorks.removeAll { selectedWorks.contains($0.id) }
        
        // 更新存储
        StorageService.shared.saveArtWorks(appState.userWorks)
        
        // 清除选择
        selectedWorks.removeAll()
        isEditMode = false
    }
    
    // 导出选中作品
    private func exportSelectedWorks() {
        // 实际应用中这里应该实现导出逻辑
        print("导出 \(selectedWorks.count) 个作品")
    }
    
    // 分享选中作品
    private func shareSelectedWorks() {
        // 实际应用中这里应该实现分享逻辑
        print("分享 \(selectedWorks.count) 个作品")
    }
}

// 过滤按钮
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 网格中的作品项
struct ArtworkGridItem: View {
    let artwork: ArtWork
    let isEditMode: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                VStack(alignment: .leading) {
                    // 图片
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 160)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: artwork.type.iconName)
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // 标题
                    Text(artwork.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // 日期
                    Text(formattedDate(artwork.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isEditMode ? 0.7 : 1.0)
            
            // 编辑模式下的选择按钮
            if isEditMode {
                Button(action: onSelect) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 18, height: 18)
                        } else {
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 18, height: 18)
                        }
                    }
                    .padding(8)
                }
            }
        }
        .onAppear {
            // 加载图片
            loadImage()
        }
    }
    
    // 加载图片
    private func loadImage() {
        if let sketchImageUrl = artwork.sketchImageUrl {
            image = StorageService.shared.loadImage(fileName: sketchImageUrl, from: .sketch)
        } else {
            image = StorageService.shared.loadImage(fileName: artwork.imageUrl, from: .original)
        }
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// 作品详情视图
struct ArtworkDetailView: View {
    let artwork: ArtWork
    
    @State private var originalImage: UIImage?
    @State private var sketchImage: UIImage?
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 图片预览区域
                VStack(spacing: 15) {
                    // 标题
                    Text(artwork.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // 原图和转换后的图片展示
                    HStack {
                        // 原图
                        VStack {
                            Text("原图")
                                .font(.headline)
                            
                            if let originalImage = originalImage {
                                Image(uiImage: originalImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            }
                        }
                        
                        // 素描图
                        VStack {
                            Text("素描")
                                .font(.headline)
                            
                            if let sketchImage = sketchImage {
                                Image(uiImage: sketchImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                
                // 作品信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("作品信息")
                        .font(.headline)
                    
                    HStack {
                        Label(artwork.type.rawValue, systemImage: artwork.type.iconName)
                        Spacer()
                        Text(formattedDate(artwork.createdAt))
                            .foregroundColor(.gray)
                    }
                    
                    if let settings = artwork.settings {
                        Divider()
                        
                        Text("转换设置")
                            .font(.headline)
                        
                        HStack {
                            Text("素描风格")
                            Spacer()
                            Text(settings.sketchStyle.rawValue)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("线条粗细")
                            Spacer()
                            Text("\(settings.lineThickness)")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("对比度")
                            Spacer()
                            Text("\(settings.contrast)%")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 操作按钮
                HStack(spacing: 20) {
                    // 打印按钮
                    Button(action: {
                        // 打印功能
                    }) {
                        VStack {
                            Image(systemName: "printer")
                                .font(.title2)
                            Text("打印")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // 导出按钮
                    Button(action: {
                        // 导出功能
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.title2)
                            Text("导出")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // 分享按钮
                    Button(action: {
                        prepareShareImage()
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            Text("分享")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("作品详情", displayMode: .inline)
        .onAppear {
            loadImages()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage = shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }
    
    // 加载图片
    private func loadImages() {
        originalImage = StorageService.shared.loadImage(fileName: artwork.imageUrl, from: .original)
        
        if let sketchImageUrl = artwork.sketchImageUrl {
            sketchImage = StorageService.shared.loadImage(fileName: sketchImageUrl, from: .sketch)
        }
    }
    
    // 准备分享图片
    private func prepareShareImage() {
        guard let originalImage = originalImage, let sketchImage = sketchImage else {
            return
        }
        
        shareImage = StorageService.shared.createShareImage(original: originalImage, sketch: sketchImage)
        showingShareSheet = true
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// 活动视图（用于分享）
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 预览
struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GalleryView()
        }
        .environmentObject(AppState())
    }
} 