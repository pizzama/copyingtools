//
//  ImageProcessingService.swift
//  copyingtools
//
//  Created for KidsDraw app.
//

import Foundation
import UIKit
import Combine
import CoreImage.CIFilterBuiltins

class ImageProcessingService {
    static let shared = ImageProcessingService()
    
    private let context = CIContext()
    private let queue = DispatchQueue(label: "com.kidsdraw.imageprocessing", qos: .userInitiated)
    
    // 进度处理
    private var progressSubject = CurrentValueSubject<Float, Never>(0.0)
    var progressPublisher: AnyPublisher<Float, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    
    // 将图片转换为素描
    func convertToSketch(
        image: UIImage, 
        style: SketchStyle, 
        lineThickness: Int, 
        contrast: Int,
        saturation: Int,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 重置进度
                self.progressSubject.send(0.0)
                
                // 转换逻辑
                var processedImage: UIImage?
                
                switch style {
                case .outline:
                    processedImage = try self.createOutlineImage(from: image, lineThickness: lineThickness, contrast: contrast)
                case .sketch:
                    processedImage = try self.createSketchImage(from: image, lineThickness: lineThickness, contrast: contrast)
                case .cartoon:
                    processedImage = try self.createCartoonImage(from: image, lineThickness: lineThickness, contrast: contrast, saturation: saturation)
                }
                
                // 确保处理成功
                guard let finalImage = processedImage else {
                    throw ImageProcessingError.processingFailed
                }
                
                // 完成
                self.progressSubject.send(1.0)
                
                // 返回主线程
                DispatchQueue.main.async {
                    completion(.success(finalImage))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // 轮廓线风格
    private func createOutlineImage(from image: UIImage, lineThickness: Int, contrast: Int) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessingError.invalidInput
        }
        
        self.progressSubject.send(0.2)
        
        // 转换为灰度图
        let grayFilter = CIFilter.colorControls()
        grayFilter.inputImage = ciImage
        grayFilter.saturation = 0
        
        guard let grayImage = grayFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.4)
        
        // 应用边缘检测
        let edgeFilter = CIFilter.edges()
        edgeFilter.inputImage = grayImage
        edgeFilter.intensity = Float(lineThickness) * 0.5
        
        guard let edgeImage = edgeFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.6)
        
        // 调整对比度
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = edgeImage
        contrastFilter.contrast = Float(contrast) / 50.0
        
        guard let outputImage = contrastFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.8)
        
        // 图像反转
        let invertFilter = CIFilter.colorInvert()
        invertFilter.inputImage = outputImage
        
        guard let finalCIImage = invertFilter.outputImage,
              let cgImage = context.createCGImage(finalCIImage, from: finalCIImage.extent) else {
            throw ImageProcessingError.processingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // 素描风格
    private func createSketchImage(from image: UIImage, lineThickness: Int, contrast: Int) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessingError.invalidInput
        }
        
        self.progressSubject.send(0.3)
        
        // 转换为灰度图
        let grayFilter = CIFilter.colorControls()
        grayFilter.inputImage = ciImage
        grayFilter.saturation = 0
        
        guard let grayImage = grayFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.5)
        
        // 应用高斯模糊，然后执行颜色反转
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = grayImage
        blurFilter.radius = 1.0
        
        guard let blurredImage = blurFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        // 颜色反转
        let invertFilter = CIFilter.colorInvert()
        invertFilter.inputImage = blurredImage
        
        guard let invertedImage = invertFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.7)
        
        // 混合模式 - 用原始灰度图和反转的模糊图像做颜色减淡混合
        let blendFilter = CIFilter.colorDodgeBlendMode()
        blendFilter.inputImage = invertedImage
        blendFilter.backgroundImage = grayImage
        
        guard let outputImage = blendFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.9)
        
        // 调整对比度
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = outputImage
        contrastFilter.contrast = Float(contrast) / 50.0
        
        guard let finalCIImage = contrastFilter.outputImage,
              let cgImage = context.createCGImage(finalCIImage, from: finalCIImage.extent) else {
            throw ImageProcessingError.processingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // 卡通风格
    private func createCartoonImage(from image: UIImage, lineThickness: Int, contrast: Int, saturation: Int) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessingError.invalidInput
        }
        
        self.progressSubject.send(0.2)
        
        // 平滑处理
        let smoothFilter = CIFilter.median()
        smoothFilter.inputImage = ciImage
        smoothFilter.setValue(Float(lineThickness), forKey: "inputRadius")
        
        guard let smoothImage = smoothFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.4)
        
        // 边缘检测
        let edgeFilter = CIFilter.edges()
        edgeFilter.inputImage = ciImage
        edgeFilter.intensity = Float(lineThickness) * 0.5
        
        guard let edgeImage = edgeFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        // 颜色反转边缘
        let invertFilter = CIFilter.colorInvert()
        invertFilter.inputImage = edgeImage
        
        guard let invertedEdges = invertFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.6)
        
        // 调整饱和度和对比度
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = smoothImage
        colorFilter.saturation = Float(saturation) / 50.0
        colorFilter.contrast = Float(contrast) / 50.0
        
        guard let colorAdjustedImage = colorFilter.outputImage else {
            throw ImageProcessingError.processingFailed
        }
        
        self.progressSubject.send(0.8)
        
        // 合并边缘和颜色调整后的图像
        let compositeFilter = CIFilter.sourceOverCompositing()
        compositeFilter.inputImage = invertedEdges
        compositeFilter.backgroundImage = colorAdjustedImage
        
        guard let finalCIImage = compositeFilter.outputImage,
              let cgImage = context.createCGImage(finalCIImage, from: finalCIImage.extent) else {
            throw ImageProcessingError.processingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// 处理错误
enum ImageProcessingError: Error {
    case invalidInput
    case processingFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidInput:
            return "无效的输入图像"
        case .processingFailed:
            return "图像处理失败"
        }
    }
} 