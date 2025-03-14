//
//  CategoryGalleryView.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import SwiftUI

struct CategoryGalleryView: View {
    let category: String
    @State private var selectedImage: UIImage?
    @State private var isNavigatingToConvert = false
    
    // 根据分类获取图片数据
    private var images: [GalleryImage] {
        switch category {
        case "动物":
            return [
                GalleryImage(id: 1, name: "小猫", imageName: "cat"),
                GalleryImage(id: 2, name: "小狗", imageName: "dog"),
                GalleryImage(id: 3, name: "兔子", imageName: "rabbit"),
                GalleryImage(id: 4, name: "大象", imageName: "elephant"),
                GalleryImage(id: 5, name: "长颈鹿", imageName: "giraffe"),
                GalleryImage(id: 6, name: "熊猫", imageName: "panda"),
                GalleryImage(id: 7, name: "狮子", imageName: "lion"),
                GalleryImage(id: 8, name: "猴子", imageName: "monkey"),
                GalleryImage(id: 9, name: "鱼", imageName: "fish"),
                GalleryImage(id: 10, name: "鸟", imageName: "bird"),
                GalleryImage(id: 11, name: "蝴蝶", imageName: "butterfly"),
                GalleryImage(id: 12, name: "乌龟", imageName: "turtle")
            ]
        case "植物":
            return [
                GalleryImage(id: 1, name: "树", imageName: "tree"),
                GalleryImage(id: 2, name: "花", imageName: "flower"),
                GalleryImage(id: 3, name: "草", imageName: "grass"),
                GalleryImage(id: 4, name: "仙人掌", imageName: "cactus"),
                GalleryImage(id: 5, name: "向日葵", imageName: "sunflower"),
                GalleryImage(id: 6, name: "苹果", imageName: "apple"),
                GalleryImage(id: 7, name: "香蕉", imageName: "banana"),
                GalleryImage(id: 8, name: "草莓", imageName: "strawberry")
            ]
        case "交通工具":
            return [
                GalleryImage(id: 1, name: "汽车", imageName: "car"),
                GalleryImage(id: 2, name: "自行车", imageName: "bicycle"),
                GalleryImage(id: 3, name: "公交车", imageName: "bus"),
                GalleryImage(id: 4, name: "火车", imageName: "train"),
                GalleryImage(id: 5, name: "飞机", imageName: "airplane"),
                GalleryImage(id: 6, name: "船", imageName: "boat"),
                GalleryImage(id: 7, name: "直升机", imageName: "helicopter"),
                GalleryImage(id: 8, name: "火箭", imageName: "rocket"),
                GalleryImage(id: 9, name: "救护车", imageName: "ambulance"),
                GalleryImage(id: 10, name: "警车", imageName: "police_car")
            ]
        case "卡通人物":
            return [
                GalleryImage(id: 1, name: "男孩", imageName: "boy"),
                GalleryImage(id: 2, name: "女孩", imageName: "girl"),
                GalleryImage(id: 3, name: "机器人", imageName: "robot"),
                GalleryImage(id: 4, name: "超人", imageName: "superman"),
                GalleryImage(id: 5, name: "公主", imageName: "princess"),
                GalleryImage(id: 6, name: "王子", imageName: "prince"),
                GalleryImage(id: 7, name: "小丑", imageName: "clown"),
                GalleryImage(id: 8, name: "仙女", imageName: "fairy"),
                GalleryImage(id: 9, name: "海盗", imageName: "pirate"),
                GalleryImage(id: 10, name: "宇航员", imageName: "astronaut"),
                GalleryImage(id: 11, name: "消防员", imageName: "firefighter"),
                GalleryImage(id: 12, name: "医生", imageName: "doctor"),
                GalleryImage(id: 13, name: "老师", imageName: "teacher"),
                GalleryImage(id: 14, name: "厨师", imageName: "chef"),
                GalleryImage(id: 15, name: "警察", imageName: "police")
            ]
        case "简单形状":
            return [
                GalleryImage(id: 1, name: "圆形", imageName: "circle"),
                GalleryImage(id: 2, name: "正方形", imageName: "square"),
                GalleryImage(id: 3, name: "三角形", imageName: "triangle"),
                GalleryImage(id: 4, name: "星形", imageName: "star"),
                GalleryImage(id: 5, name: "心形", imageName: "heart"),
                GalleryImage(id: 6, name: "六边形", imageName: "hexagon"),
                GalleryImage(id: 7, name: "五边形", imageName: "pentagon"),
                GalleryImage(id: 8, name: "箭头", imageName: "arrow")
            ]
        default:
            return []
        }
    }
    
    // 网格布局
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(images) { image in
                    GalleryImageCard(image: image) {
                        // 在实际应用中，这里应该加载真实图片
                        selectedImage = UIImage(systemName: "photo")
                        isNavigatingToConvert = true
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: ConvertView(originalImage: selectedImage ?? UIImage()),
                isActive: $isNavigatingToConvert,
                label: { EmptyView() }
            )
            .hidden()
        )
    }
}

// 图库中的图片数据模型
struct GalleryImage: Identifiable {
    let id: Int
    let name: String
    let imageName: String
}

// 图库中的图片卡片
struct GalleryImageCard: View {
    let image: GalleryImage
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                // 在实际应用中，这里应该加载真实图片
                // Image(image.imageName)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
                
                Text(image.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 预览
struct CategoryGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryGalleryView(category: "动物")
        }
    }
} 