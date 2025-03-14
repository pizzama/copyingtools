//
//  UploadView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isShowingCamera = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var photoItem: PhotosPickerItem?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // 顶部标题
            Text("选择图片")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            // 已选图片预览
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding()
                    .shadow(radius: 5)
                
                // 继续按钮
                Button(action: {
                    // 跳转到图片转换页面，传递选择的图片
                    // 此处应该将处理图片的逻辑封装在一个服务中
                }) {
                    Text("继续处理")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                // 上传选项卡片
                uploadOptionsView
            }
            
            Spacer()
        }
        .navigationTitle("选择图片")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSource)
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraPicker(selectedImage: $selectedImage)
        }
    }
    
    // 上传选项视图
    private var uploadOptionsView: some View {
        VStack(spacing: 20) {
            // 相机选项
            UploadOptionCard(
                title: "拍摄照片",
                subtitle: "使用相机拍摄一张新图片",
                iconName: "camera.fill",
                color: .blue
            ) {
                isShowingCamera = true
            }
            
            // 相册选项
            UploadOptionCard(
                title: "从相册选择",
                subtitle: "从您的相册中选择图片",
                iconName: "photo.on.rectangle.angled",
                color: .purple
            ) {
                imagePickerSource = .photoLibrary
                isShowingImagePicker = true
            }
            
            // 默认图库选项
            NavigationLink(destination: DefaultGalleryView(selectedImage: $selectedImage)) {
                UploadOptionCard(
                    title: "从默认图库选择",
                    subtitle: "选择我们提供的图片",
                    iconName: "square.grid.2x2.fill",
                    color: .orange,
                    action: nil
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
}

// 上传选项卡片
struct UploadOptionCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                    
                    Text(subtitle)
                        .font(.subheadline)
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
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            picker.dismiss(animated: true)
        }
    }
}

// 相机选择器
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            picker.dismiss(animated: true)
        }
    }
}

// 默认图库视图（简化实现）
struct DefaultGalleryView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    // 模拟默认图库数据
    let categories = ["动物", "植物", "交通工具", "卡通人物", "简单形状"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            // 这里应该从资源包中加载图片
                            ForEach(1...5, id: \.self) { _ in
                                Button(action: {
                                    // 模拟选择默认图片
                                    selectedImage = UIImage(systemName: "photo")
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    VStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.largeTitle)
                                                    .foregroundColor(.gray)
                                            )
                                        
                                        Text("示例图片")
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("默认图库")
    }
}

// 预览
struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadView()
        }
    }
} 