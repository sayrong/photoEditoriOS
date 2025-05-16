//
//  ImageExportService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 16.05.2025.
//
import UIKit
import PencilKit

protocol IImageExportService {
    func exportCanvas(canvasSize: CGSize, canvasView: PKCanvasView, image: UIImage, photoState: PhotoEditState) -> UIImage
}

final class ImageExportService: IImageExportService {
    
    func exportCanvas(canvasSize: CGSize, canvasView: PKCanvasView, image: UIImage, photoState: PhotoEditState) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let renderedImage = renderer.image { ctx in
            let context = ctx.cgContext
            // Рисуем белый фон
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))
            // Рисуем Image
            drawImage(into: context, canvasSize, image, photoState)
            // Элементы PencilKit
            canvasView.drawHierarchy(in: CGRect(origin: .zero, size: canvasSize), afterScreenUpdates: true)
            // Текстовые стикеры
            drawTextStickers(into: context, photoState.texts, canvasSize)
        }
        return renderedImage
    }
    
    private func drawImage(into context: CGContext, _ canvasSize: CGSize, _ image: UIImage, _ photoState: PhotoEditState) {
        let imageOffset = photoState.position
        let imageRotation = photoState.rotation.degrees * .pi / 180
        let imageScale = photoState.scale
        let imageSize = calculateImageSize(originalSize: image.size,
                                           containerSize: canvasSize)
        
        // Позиция куда будем вписывать
        let imageRect = calculateImageRect(imageSize: imageSize,
                                           viewSize: canvasSize)
        // Создаем копию контекста и применяем трансформации
        context.saveGState()
        // Смещение на imageOffset (без влияния масштаба)
        context.translateBy(x: imageOffset.width, y: imageOffset.height)
        // Смещение в центр изображения для масштабирования и поворота
        context.translateBy(x: imageRect.midX, y: imageRect.midY)
        // Применяем масштабирование и поворот
        context.scaleBy(x: imageScale, y: imageScale)
        context.rotate(by: imageRotation)
        // Возвращаем точку отсчёта в угол изображения
        context.translateBy(x: -imageRect.midX, y: -imageRect.midY)
        // Рисуем изображение
        image.draw(in: imageRect)
        // Восстанавливаем состояние
        context.restoreGState()
    }
    
    // Функция для расчета размера изображения в контейнере
    private func calculateImageSize(originalSize: CGSize, containerSize: CGSize) -> CGSize {
        let widthRatio = containerSize.width / originalSize.width
        let heightRatio = containerSize.height / originalSize.height
        let minRatio = min(widthRatio, heightRatio)
        
        return CGSize(
            width: originalSize.width * minRatio,
            height: originalSize.height * minRatio
        )
    }

    private func calculateImageRect(imageSize: CGSize, viewSize: CGSize) -> CGRect {
        return CGRect(
            x: (viewSize.width - imageSize.width) / 2,
            y: (viewSize.height - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )
    }
    
    private func drawTextStickers(into context: CGContext, _ textStickers: [PhotoText], _ canvasSize: CGSize) {
        for text in textStickers {
            // Настройка текста
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.red
            ]
            let attrString = NSAttributedString(string: text.text, attributes: attributes)
            // Считаем размеры текста
            let maxWidth: CGFloat = 300
            let textSize = attrString.boundingRect(
                with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).integral.size
            // Работа с контекстом
            context.saveGState()
            // Переносим координаты в центр канвы + offset
            context.translateBy(x: canvasSize.width / 2 + text.offset.width,
                                y: canvasSize.height / 2 + text.offset.height)
            // Применяем поворот
            context.rotate(by: CGFloat(text.rotation.radians))
            // Применяем масштаб
            context.scaleBy(x: text.scale, y: text.scale)
            // Центрируем текст (т.к. теперь (0,0) — центр текста)
            context.translateBy(x: -textSize.width / 2, y: -textSize.height / 2)
            attrString.draw(in: CGRect(origin: .zero, size: textSize))
            context.restoreGState()
        }
    }
}
