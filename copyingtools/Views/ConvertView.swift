//
//  ConvertView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI
import Combine

struct ConvertView: View {
    // 原始图片
    let originalImage: UIImage
    
    // 状态变量
    @State private var convertedImage: UIImage?
    @State private var isProcessing = false
    @State private var processingProgress: Float = 0
    @State private var showingSaveSuccess = false
    
    // 转换参数设置
    @State private var selectedStyle: SketchStyle = .outline
    @State private var lineThickness: Double = 3
    @State private var contrast: Double = 50
    @State private var saturation: Double = 50
    
    // 取消处理令牌
    @State private var cancellable: AnyCancellable?
    
    // 环境对象
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 图片预览区域
                imagePreviewSection
                
                // 风格选择区域
                styleSelectionSection
                
                // 参数调节区域
                parameterAdjustmentSection
                
                // 操作按钮区域
                actionButtonsSection
            }
            .padding()
        }
        .navigationTitle("图片转换")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveArtwork) {
                    Image(systemName: "square.and.arrow.down")
                }
                .disabled(convertedImage == nil || isProcessing)
            }
        }
        .overlay(
            // 加载指示器
            Group {
                if isProcessing {
                    processingOverlay
                }
            }
        )
        .alert(isPresented: $showingSaveSuccess) {
            Alert(
                title: Text("保存成功"),
                message: Text("图片已保存到您的作品集"),
                dismissButton: .default(Text("确定"))
            )
        }
        .onAppear {
            // 自动开始初始转换
            convertImage()
            
            // 订阅进度更新
            cancellable = ImageProcessingService.shared.progressPublisher
                .receive(on: RunLoop.main)
                .sink { progress in
                    self.processingProgress = progress
                }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
    
    // 图片预览区域
    private var imagePreviewSection: some View {
        VStack(spacing: 15) {
            // 原图和转换后的图片展示
            HStack {
                // 原图
                VStack {
                    Text("原图")
                        .font(.headline)
                    
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                
                // 转换后的图片
                VStack {
                    Text("转换后")
                        .font(.headline)
                    
                    if let convertedImage = convertedImage {
                        Image(uiImage: convertedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .cornerRadius(8)
                            .overlay(
                                Text("等待转换")
                                    .foregroundColor(.gray)
                            )
                    }
                }
            }
        }
    }
    
    // 风格选择区域
    private var styleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("选择素描风格")
                .font(.headline)
            
            HStack {
                ForEach(SketchStyle.allCases, id: \.self) { style in
                    StyleButton(
                        title: style.rawValue,
                        isSelected: selectedStyle == style,
                        action: {
                            selectedStyle = style
                            convertImage()
                        }
                    )
                }
            }
        }
    }
    
    // 参数调节区域
    private var parameterAdjustmentSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("调整参数")
                .font(.headline)
            
            // 线条粗细滑块
            VStack(alignment: .leading) {
                HStack {
                    Text("线条粗细")
                    Spacer()
                    Text("\(Int(lineThickness))")
                }
                .font(.subheadline)
                
                Slider(
                    value: $lineThickness,
                    in: 1...5,
                    step: 1,
                    onEditingChanged: { _ in convertImage() }
                )
            }
            
            // 对比度滑块
            VStack(alignment: .leading) {
                HStack {
                    Text("对比度")
                    Spacer()
                    Text("\(Int(contrast))%")
                }
                .font(.subheadline)
                
                Slider(
                    value: $contrast,
                    in: 0...100,
                    step: 1,
                    onEditingChanged: { _ in convertImage() }
                )
            }
            
            // 饱和度滑块（仅卡通模式显示）
            if selectedStyle == .cartoon {
                VStack(alignment: .leading) {
                    HStack {
                        Text("饱和度")
                        Spacer()
                        Text("\(Int(saturation))%")
                    }
                    .font(.subheadline)
                    
                    Slider(
                        value: $saturation,
                        in: 0...100,
                        step: 1,
                        onEditingChanged: { _ in convertImage() }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 操作按钮区域
    private var actionButtonsSection: some View {
        HStack {
            // 重置按钮
            Button(action: resetParameters) {
                Text("重置")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            
            // 继续按钮
            Button(action: {
                if let convertedImage = convertedImage {
                    // 跳转到临摹编辑页面
                }
            }) {
                Text("开始临摹")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .disabled(convertedImage == nil || isProcessing)
        }
    }
    
    // 处理中遮罩
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("正在处理...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 进度条
                ProgressView(value: processingProgress, total: 1.0)
                    .frame(width: 200)
                
                Text("\(Int(processingProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color(.systemBackground).opacity(0.8))
            .cornerRadius(15)
        }
    }
    
    // MARK: - 功能方法
    
    // 执行图像转换
    private func convertImage() {
        guard !isProcessing else { return }
        
        isProcessing = true
        
        ImageProcessingService.shared.convertToSketch(
            image: originalImage,
            style: selectedStyle,
            lineThickness: Int(lineThickness),
            contrast: Int(contrast),
            saturation: Int(saturation)
        ) { result in
            isProcessing = false
            
            switch result {
            case .success(let image):
                self.convertedImage = image
            case .failure(let error):
                print("图像处理失败: \(error.localizedDescription)")
                // 在实际应用中应显示错误提示
            }
        }
    }
    
    // 重置参数
    private func resetParameters() {
        lineThickness = 3
        contrast = 50
        saturation = 50
        convertImage()
    }
    
    // 保存作品
    private func saveArtwork() {
        guard let convertedImage = convertedImage else { return }
        
        // 保存原图
        guard let originalFileName = StorageService.shared.saveOriginalImage(originalImage, withName: "original") else {
            return
        }
        
        // 保存转换后的图片
        guard let sketchFileName = StorageService.shared.saveSketchImage(convertedImage, withName: "sketch") else {
            return
        }
        
        // 创建新作品
        let artwork = ArtWork(
            title: "未命名作品",
            type: .other,
            createdAt: Date(),
            imageUrl: originalFileName,
            sketchImageUrl: sketchFileName,
            settings: ArtWorkSettings(
                sketchStyle: selectedStyle,
                lineThickness: Int(lineThickness),
                contrast: Int(contrast),
                saturation: Int(saturation)
            )
        )
        
        // 更新用户作品列表
        appState.userWorks.insert(artwork, at: 0)
        
        // 保存作品列表
        StorageService.shared.saveArtWorks(appState.userWorks)
        
        // 显示成功提示
        showingSaveSuccess = true
    }
}

// 风格选择按钮
struct StyleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 预览
struct ConvertView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConvertView(originalImage: UIImage(systemName: "photo")!)
        }
        .environmentObject(AppState())
    }
} 