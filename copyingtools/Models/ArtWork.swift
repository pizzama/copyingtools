//
//  ArtWork.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import Foundation
import SwiftUI

struct ArtWork: Identifiable, Codable {
    var id = UUID()
    var title: String
    var type: ArtWorkType
    var createdAt: Date
    var lastModifiedAt: Date = Date()
    var imageUrl: String
    var sketchImageUrl: String?
    var settings: ArtWorkSettings?
    var isFavorite: Bool = false
    
    // 作品完成度 (0-100)
    var completionPercentage: Int = 100
    
    // 导出历史记录
    var exportHistory: [ExportRecord] = []
    
    // 临时属性，不参与编码
    var image: UIImage? = nil
    var sketchImage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, title, type, createdAt, lastModifiedAt, imageUrl, sketchImageUrl, settings, isFavorite, completionPercentage, exportHistory
        // 临时属性不参与编码
    }
}

// 作品类型
enum ArtWorkType: String, Codable, CaseIterable {
    case animal = "动物"
    case plant = "植物"
    case transport = "交通工具"
    case cartoon = "卡通人物"
    case shape = "形状"
    case other = "其他"
    
    var iconName: String {
        switch self {
        case .animal: return "hare"
        case .plant: return "leaf"
        case .transport: return "car"
        case .cartoon: return "person.fill"
        case .shape: return "square.on.circle"
        case .other: return "star"
        }
    }
}

// 作品设置
struct ArtWorkSettings: Codable {
    // 素描风格
    var sketchStyle: SketchStyle = .outline
    
    // 线条粗细 (1-5)
    var lineThickness: Int = 3
    
    // 对比度 (0-100)
    var contrast: Int = 50
    
    // 饱和度 (0-100)
    var saturation: Int = 50
    
    // 颜色选择
    var color: String = "#000000"
}

// 素描风格
enum SketchStyle: String, Codable, CaseIterable {
    case outline = "轮廓线"
    case sketch = "素描"
    case cartoon = "卡通"
}

// 导出记录
struct ExportRecord: Identifiable, Codable {
    var id = UUID()
    var exportDate: Date
    var format: String
    var fileName: String
} 