//
//  EditView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI
import PencilKit

struct EditView: View {
    // 图片数据
    let sketchImage: UIImage
    let originalImage: UIImage
    
    // 画布状态
    @State private var canvasView = PKCanvasView()
    @State private var drawingIsActive = true
    @State private var toolPickerIsActive = true
    @State private var showingColorPicker = false
    @State private var selectedColor = Color.black
    @State private var lineWidth: CGFloat = 5
    @State private var drawingOpacity: CGFloat = 1.0
    @State private var showingReferenceImage = true
    @State private var showingSaveSuccessAlert = false
    @State private var showingSaveFailureAlert = false
    @State private var showingDiscardAlert = false
    @State private var saveErrorMessage = ""
    
    // 环境变量
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                editToolbar
                
                // 画布区域
                ZStack {
                    // 素描图作为参考
                    if showingReferenceImage {
                        Image(uiImage: sketchImage)
                            .resizable()
                            .scaledToFit()
                            .opacity(drawingOpacity)
                    }
                    
                    // 绘图画布
                    DrawingCanvas(canvasView: $canvasView, toolPickerIsActive: $toolPickerIsActive)
                        .opacity(drawingIsActive ? 1 : 0)
                }
                .background(Color(.systemBackground))
                
                // 底部控制栏
                bottomControlBar
            }
            
            // 颜色选择器
            if showingColorPicker {
                ColorPickerView(
                    selectedColor: $selectedColor,
                    lineWidth: $lineWidth,
                    isVisible: $showingColorPicker
                )
                .transition(.move(edge: .bottom))
            }
        }
        .navigationTitle("临摹绘画")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 自定义返回按钮
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if !canvasView.drawing.bounds.isEmpty {
                        showingDiscardAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            
            // 保存按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveDrawing) {
                    Text("保存")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert(isPresented: $showingSaveSuccessAlert) {
            Alert(
                title: Text("保存成功"),
                message: Text("您的临摹作品已保存到作品集"),
                dismissButton: .default(Text("确定")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingSaveFailureAlert) {
            Alert(
                title: Text("保存失败"),
                message: Text(saveErrorMessage),
                dismissButton: .default(Text("确定"))
            )
        }
        .alert(isPresented: $showingDiscardAlert) {
            Alert(
                title: Text("放弃绘画?"),
                message: Text("您的绘画尚未保存，离开将丢失当前绘画。"),
                primaryButton: .destructive(Text("放弃")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("继续绘画"))
            )
        }
    }
    
    // 顶部工具栏
    private var editToolbar: some View {
        HStack(spacing: 20) {
            // 显示/隐藏参考图
            Button(action: {
                withAnimation {
                    showingReferenceImage.toggle()
                }
            }) {
                VStack {
                    Image(systemName: showingReferenceImage ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 20))
                    Text("参考图")
                        .font(.caption)
                }
                .foregroundColor(showingReferenceImage ? .accentColor : .gray)
            }
            
            // 画布透明度调节
            VStack {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.system(size: 18))
                    Slider(value: $drawingOpacity, in: 0.1...1.0)
                        .frame(width: 100)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 18))
                }
                
                Text("透明度")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            
            // 撤销按钮
            Button(action: {
                canvasView.undoManager?.undo()
            }) {
                VStack {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 20))
                    Text("撤销")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            }
            
            // 重做按钮
            Button(action: {
                canvasView.undoManager?.redo()
            }) {
                VStack {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 20))
                    Text("重做")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            }
            
            // 清除按钮
            Button(action: {
                canvasView.drawing = PKDrawing()
            }) {
                VStack {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    Text("清除")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // 底部控制栏
    private var bottomControlBar: some View {
        HStack(spacing: 30) {
            // 绘画/橡皮擦切换
            Button(action: {
                toggleDrawingMode()
            }) {
                VStack {
                    Image(systemName: drawingIsActive ? "pencil.tip" : "eraser")
                        .font(.system(size: 24))
                    Text(drawingIsActive ? "绘画" : "橡皮擦")
                        .font(.caption)
                }
                .foregroundColor(drawingIsActive ? .accentColor : .primary)
            }
            
            // 颜色选择
            Button(action: {
                withAnimation {
                    showingColorPicker.toggle()
                }
            }) {
                VStack {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text("颜色")
                        .font(.caption)
                }
            }
            
            // 线条粗细
            VStack {
                HStack {
                    Image(systemName: "minus")
                        .font(.system(size: 16))
                    Slider(value: $lineWidth, in: 1...20)
                        .frame(width: 100)
                        .onChange(of: lineWidth) { newValue in
                            updatePencilToolSettings()
                        }
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                }
                Text("线条粗细")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            
            // 对比参考按钮
            Button(action: {
                // 切换显示原图和素描图
                withAnimation {
                    showingReferenceImage.toggle()
                }
            }) {
                VStack {
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 24))
                    Text("对比")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // 保存绘画
    private func saveDrawing() {
        // 获取画布上的绘画内容
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        // 保存到相册或应用内存储
        guard let drawingFileName = StorageService.shared.saveSketchImage(image, withName: "drawing") else {
            saveErrorMessage = "无法保存图像文件"
            showingSaveFailureAlert = true
            return
        }
        
        // 保存原始素描图
        guard let sketchFileName = StorageService.shared.saveSketchImage(sketchImage, withName: "sketch_reference") else {
            saveErrorMessage = "无法保存参考图像文件"
            showingSaveFailureAlert = true
            return
        }
        
        // 创建新作品记录
        let artwork = ArtWork(
            title: "我的临摹作品",
            type: .other,
            createdAt: Date(),
            imageUrl: drawingFileName,
            sketchImageUrl: sketchFileName
        )
        
        // 更新作品集
        appState.userWorks.insert(artwork, at: 0)
        StorageService.shared.saveArtWorks(appState.userWorks)
        
        // 显示成功提示
        showingSaveSuccessAlert = true
    }
    
    // 切换绘画模式（绘制/橡皮擦）
    private func toggleDrawingMode() {
        drawingIsActive.toggle()
        if toolPickerIsActive {
            canvasView.tool = drawingIsActive ? PKInkingTool(.pen, color: UIColor(selectedColor), width: lineWidth) : PKEraserTool(.vector)
        }
    }
    
    // 更新笔刷设置
    private func updatePencilToolSettings() {
        if drawingIsActive {
            canvasView.tool = PKInkingTool(.pen, color: UIColor(selectedColor), width: lineWidth)
        }
    }
}

// PencilKit绘图画布
struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPickerIsActive: Bool
    
    let toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        
        toolPicker.setVisible(toolPickerIsActive, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        toolPicker.setVisible(toolPickerIsActive, forFirstResponder: uiView)
    }
}

// 颜色选择器视图
struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var lineWidth: CGFloat
    @Binding var isVisible: Bool
    
    // 预定义颜色
    let colors: [Color] = [
        .black, .gray, .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题和关闭按钮
            HStack {
                Text("选择颜色")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // 预定义颜色选择器
            HStack(spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                                .padding(2)
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.black : Color.gray, lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()
            
            // 自定义颜色选择器
            ColorPicker("自定义颜色", selection: $selectedColor)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

// 预览
struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(
            sketchImage: UIImage(systemName: "scribble")!,
            originalImage: UIImage(systemName: "photo")!
        )
        .environmentObject(AppState())
    }
} 