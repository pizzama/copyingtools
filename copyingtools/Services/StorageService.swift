//
//  StorageService.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import Foundation
import UIKit

class StorageService {
    static let shared = StorageService()
    
    private let fileManager = FileManager.default
    private let userDefaultsKey = "com.kidsdraw.userdata"
    private let artworkDefaultsKey = "com.kidsdraw.artworks"
    
    // 文件目录
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var imagesDirectory: URL {
        let directory = documentsDirectory.appendingPathComponent("images")
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private var sketchesDirectory: URL {
        let directory = documentsDirectory.appendingPathComponent("sketches")
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private var tempDirectory: URL {
        let directory = documentsDirectory.appendingPathComponent("temp")
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    // MARK: - 用户数据管理
    
    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("保存用户数据失败: \(error.localizedDescription)")
        }
    }
    
    func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            print("加载用户数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 作品数据管理
    
    func saveArtWorks(_ artworks: [ArtWork]) {
        do {
            let data = try JSONEncoder().encode(artworks)
            UserDefaults.standard.set(data, forKey: artworkDefaultsKey)
        } catch {
            print("保存作品数据失败: \(error.localizedDescription)")
        }
    }
    
    func loadArtWorks() -> [ArtWork] {
        guard let data = UserDefaults.standard.data(forKey: artworkDefaultsKey) else {
            return []
        }
        
        do {
            let artworks = try JSONDecoder().decode([ArtWork].self, from: data)
            return artworks
        } catch {
            print("加载作品数据失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - 图片管理
    
    // 保存原始图片
    func saveOriginalImage(_ image: UIImage, withName name: String) -> String? {
        let fileName = "\(name)_\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("保存原始图片失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 保存素描图片
    func saveSketchImage(_ image: UIImage, withName name: String) -> String? {
        let fileName = "\(name)_\(UUID().uuidString).jpg"
        let fileURL = sketchesDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("保存素描图片失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 加载图片
    func loadImage(fileName: String, from directory: ImageDirectory) -> UIImage? {
        let directoryURL: URL
        
        switch directory {
        case .original:
            directoryURL = imagesDirectory
        case .sketch:
            directoryURL = sketchesDirectory
        case .temp:
            directoryURL = tempDirectory
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    // 删除图片
    func deleteImage(fileName: String, from directory: ImageDirectory) -> Bool {
        let directoryURL: URL
        
        switch directory {
        case .original:
            directoryURL = imagesDirectory
        case .sketch:
            directoryURL = sketchesDirectory
        case .temp:
            directoryURL = tempDirectory
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            print("删除图片失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // 清理临时文件
    func cleanupTempFiles() {
        do {
            let tempFiles = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
            for file in tempFiles {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("清理临时文件失败: \(error.localizedDescription)")
        }
    }
    
    // 导出图片到相册
    func exportImageToPhotoLibrary(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        completion(true, nil)
    }
    
    // 创建共享图片
    func createShareImage(original: UIImage, sketch: UIImage) -> UIImage? {
        let size = CGSize(width: original.size.width * 2 + 20, height: original.size.height + 60)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // 绘制背景
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // 绘制标题
        let titleText = "我的临摹作品"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (size.width - titleSize.width) / 2, y: 10, width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        // 绘制原始图片
        let originalRect = CGRect(x: 10, y: 40, width: original.size.width, height: original.size.height)
        original.draw(in: originalRect)
        
        // 绘制素描图片
        let sketchRect = CGRect(x: original.size.width + 20, y: 40, width: sketch.size.width, height: sketch.size.height)
        sketch.draw(in: sketchRect)
        
        // 获取合成后的图片
        guard let combinedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return combinedImage
    }
}

// 图片目录类型
enum ImageDirectory {
    case original
    case sketch
    case temp
} 