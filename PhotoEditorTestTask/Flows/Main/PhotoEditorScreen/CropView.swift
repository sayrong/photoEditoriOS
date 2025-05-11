//
//  CropView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 03.05.2025.
//

import SwiftUI

public enum MaskShape: CaseIterable {
    case circle, square, rectangle
}

private struct MaskShapeView: View {
    let maskShape: MaskShape

    var body: some View {
        Group {
            switch maskShape {
            case .circle:
                Circle()
            case .square, .rectangle:
                Rectangle()
            }
        }
    }
}

class CropViewModel: ObservableObject {
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
//    func cropImage() {
//        let renderer = ImageRenderer(content: imageView())
//        renderer.proposedSize = .init(cropSize)
//        if let image = renderer.uiImage {
//            print("ok")
//        } else {
//            print("not ok")
//        }
//    }
    
}

enum CropMode: CaseIterable {
    case circle
    case square
    case landscape
    case portrait
    
    func iconName() -> String {
        switch self {
        case .circle:
            "circle"
        case .square:
            "square"
        case .landscape:
            "rectangle"
        case .portrait:
            "rectangle.portrait"
        }
    }
    
    func size() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let baseSize = screenWidth * 0.7
        
        let landscapeAspectRatio: CGFloat = 4/3
        let portraitAspectRatio: CGFloat = 2/3

        switch self {
        case .circle, .square:
            return CGSize(width: baseSize, height: baseSize)
        case .landscape:
            let height = baseSize / landscapeAspectRatio
            return CGSize(width: baseSize, height: height)
        case .portrait:
            let width = baseSize * portraitAspectRatio
            return CGSize(width: width, height: baseSize)
        }
    }
    
    @ViewBuilder
    func shape() -> some View {
        switch self {
        case .circle:
            Circle()
        case .square, .landscape, .portrait:
            Rectangle()
        }
    }
}

struct CropView1: View {
    
    var image: UIImage
    var onCrop: ((UIImage?) -> Void)?
    
    @State private var cropMode: CropMode = .square
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    @State private var maskSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            cropModePanel()
            cropView()
            controlButtons()
        }
    }
    
    private func cropModePanel() -> some View {
        HStack {
            ForEach(CropMode.allCases, id: \.self) { mode in
                Button {
                    cropMode = mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(cropMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
    
    private func controlButtons() -> some View {
        HStack {
            Button("Cancel") {
                
            }
            Spacer()
            Button("Save") {
                
            }
        }
        .padding(.horizontal, 20)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.black)
    }
    
    private func cropView() -> some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    imageSize = geometry.size
                                }
                        }
                    )
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .mask(
                        cropMode.shape()
                            .frame(width: cropMode.size().width,
                                   height: cropMode.size().height)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(dragGesture())
            .gesture(scaleGesture())
        }
        .clipped()
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                let maxOffsetPoint = calculateDragGestureMax()
                let newX = min(
                    max(value.translation.width + lastOffset.width, -maxOffsetPoint.x),
                    maxOffsetPoint.x
                )
                let newY = min(
                    max(value.translation.height + lastOffset.height, -maxOffsetPoint.y),
                    maxOffsetPoint.y
                )
                offset = CGSize(width: newX, height: newY)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    private func scaleGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let scaledValue = value.magnitude
                let maxScaleValues = calculateMagnificationGestureMaxValues()
                scale = min(max(scaledValue * lastScale, maxScaleValues.0), maxScaleValues.1)
                updateOffset()
            }
            .onEnded { _ in
                lastScale = scale
                lastOffset = offset
            }
    }
    
    private func calculateDragGestureMax() -> CGPoint {
        let imageSizeInView = imageSize
        let maskSize = cropMode.size()
        let xLimit = max(0, ((imageSizeInView.width / 2) * scale) - (maskSize.width / 2))
        let yLimit = max(0, ((imageSizeInView.height / 2) * scale) - (maskSize.height / 2))
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    private func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let maxMagnificationScale: CGFloat = 4.0
        let imageSizeInView = imageSize
        let maskSize = cropMode.size()
        let minScale = max(maskSize.width / imageSizeInView.width, maskSize.height / imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }
    
    private func updateOffset() {
        let maxOffsetPoint = calculateDragGestureMax()
        let newX = min(max(offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        offset = CGSize(width: newX, height: newY)
        lastOffset = offset
    }
}

#Preview {
    CropView1(image: UIImage(named: "gotta.JPG")!)
}

struct CropView: View {
    
    var image: UIImage
    var onCrop: ((UIImage?) -> Void)?
    
    @State private var cropMode: CropMode = .square
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @GestureState var isInteracting = false
    
    @GestureState var myOffset: CGSize = .zero
    
    var body: some View {
        VStack {
//            Button {
//                let a = cropImage(originalImage: image, scale: scale, offset: offset, cropSize: cropMode.size())
//                print(a)
//            } label: {
//                Text("gg")
//            }
            
            cropModePanel()
            imageView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.black.opacity(0.8)
                }
                .ignoresSafeArea()
        }
        //imageView1()
    }
    
    func cropModePanel() -> some View {
        HStack {
            ForEach(CropMode.allCases, id: \.self) { mode in
                Button {
                    cropMode = mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(cropMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
    
    @State var imageSize: CGSize = .zero {
        didSet {
            print("my \(imageSize)")
        }
    }
    
    @State private var startLocation: CGPoint = .zero
    
    var maskShape: MaskShape = .rectangle
    
    func imageView1() -> some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    updateMaskDimensions(for: geometry.size)
                                }
                        }
                    )
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .mask(
                        MaskShapeView(maskShape: maskShape)
                            .frame(width: cropMode.size().width, height: cropMode.size().height)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let maxOffsetPoint = calculateDragGestureMax()
                        let newX = min(
                            max(value.translation.width + lastOffset.width, -maxOffsetPoint.x),
                            maxOffsetPoint.x
                        )
                        let newY = min(
                            max(value.translation.height + lastOffset.height, -maxOffsetPoint.y),
                            maxOffsetPoint.y
                        )
                        offset = CGSize(width: newX, height: newY)
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        
                        let scaledValue = value.magnitude - 1

                        let maxScaleValues = calculateMagnificationGestureMaxValues()
                        scale = min(max(scaledValue * lastScale, maxScaleValues.0), maxScaleValues.1)

                        updateOffset()
                    }
                    .onEnded { _ in
                        lastScale = scale
                        lastOffset = offset
                    }
            )
        }
        .background(Color.red)
    }
    
    @ViewBuilder
    func imageView() -> some View {
        let cropSize = cropMode.size()
        GeometryReader {
            let size = $0.size
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(content: {
                    GeometryReader { imageGeo in
                        Color.clear
                            .onAppear {
                                imageSize = imageGeo.frame(in: .named("cropSpace")).size
                            }
                    }
                })
                .frame(width: size.width, height: size.height)
                .scaleEffect(scale)
                .offset(offset)
        }
        .frame(width: cropSize.width, height: cropSize.height)
        .border(.red)
        
        .overlay {
            grid()
        }
        .coordinateSpace(name: "cropSpace")
        //.cornerRadius(cropMode == .circle ? cropSize.height / 2 : 0)
        .gesture(
            DragGesture()
//                .onChanged { value in
//                    let delta = CGSize(width: value.translation.width * scale,
//                                       height: value.translation.height * scale)
//                    let newOffset = CGSize(width: lastOffset.width + delta.width,
//                                           height: lastOffset.height + delta.height)
//                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
//                        offset = constrainOffset(newOffset)
//                    }
//                }
//                .onEnded { _ in
//                    lastOffset = offset
//                }
            
//                .onChanged { value in
//                    let maxOffsetPoint = calculateDragGestureMax()
//                    let newX = min(
//                        max(value.translation.width + lastOffset.width, -maxOffsetPoint.x),
//                        maxOffsetPoint.x
//                    )
//                    let newY = min(
//                        max(value.translation.height + lastOffset.height, -maxOffsetPoint.y),
//                        maxOffsetPoint.y
//                    )
//                    offset = CGSize(width: newX, height: newY)
//                }
//                .onEnded { _ in
//                    lastOffset = offset
//                }
            
                .onChanged { value in
                    let maxOffsetPoint = calculateDragGestureMax()
                    let newX = min(
                        max(value.translation.width + lastOffset.width, -maxOffsetPoint.x),
                        maxOffsetPoint.x
                    )
                    let newY = min(
                        max(value.translation.height + lastOffset.height, -maxOffsetPoint.y),
                        maxOffsetPoint.y
                    )
                    offset = CGSize(width: newX, height: newY)
                }
                .onEnded { _ in
                    lastOffset = offset
                }
            
        )
        // Жесты применяются непосредственно к ZStack
        .gesture(
            // Жест масштабирования
            MagnificationGesture()
                .onChanged { value in
//                    let delta = value / lastScale
//                    lastScale = value
//                    
//                    // Запоминаем текущее смещение перед изменением масштаба
//                    let oldScale = scale
//                    
//                    // Обновляем масштаб с ограничениями
//                    scale = min(max(scale * delta, 1.0), 5.0)
//                    
//                    // Важно: корректируем offset при изменении масштаба,
//                    // чтобы точка под центром рамки оставалась на том же месте
//                    let scaleRatio = scale / oldScale
//                    offset = CGSize(
//                        width: offset.width * scaleRatio,
//                        height: offset.height * scaleRatio
//                    )
//                    
//                    // Проверяем новые границы
//                    offset = calculateBoundedOffset(for: offset)
                    
                    let maxScaleValues = calculateMagnificationGestureMaxValues()
                    scale = min(max(value * lastScale, maxScaleValues.0), maxScaleValues.1)
                    
                    updateOffset()
                }
                .onEnded { _ in
                    lastScale = 1.0
                }

        )
        
    }
    
    //@State var imageSizeInView: CGSize = .zero
    @State var maskSize: CGSize = .zero
    
    var maskRadius: CGFloat = 130
    var rectAspectRatio: CGFloat = 4/3
    
    func updateMaskDimensions(for imageSizeInView: CGSize) {
        self.imageSize = imageSizeInView
        updateMaskSize(for: imageSizeInView)
    }
    
    private func updateMaskSize(for size: CGSize) {
        switch maskShape {
        case .circle, .square:
            let diameter = min(maskRadius * 2, min(size.width, size.height))
            maskSize = CGSize(width: diameter, height: diameter)
        case .rectangle:
            let maxWidth = min(size.width, maskRadius * 2)
            let maxHeight = min(size.height, maskRadius * 2)
            if maxWidth / maxHeight > rectAspectRatio {
                maskSize = CGSize(width: maxHeight * rectAspectRatio, height: maxHeight)
            } else {
                maskSize = CGSize(width: maxWidth, height: maxWidth / rectAspectRatio)
            }
        }
    }
    
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let maxMagnificationScale: CGFloat = 4.0
        let imageSizeInView = imageSize
        let maskSize = cropMode.size()
            let minScale = max(maskSize.width / imageSizeInView.width, maskSize.height / imageSizeInView.height)
            return (minScale, maxMagnificationScale)
        }
    
    private func updateOffset() {
        let maxOffsetPoint = calculateDragGestureMax()
        let newX = min(max(offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        offset = CGSize(width: newX, height: newY)
        lastOffset = offset
    }
    
    func calculateDragGestureMax() -> CGPoint {
        let imageSizeInView = imageSize
        let maskSize = cropMode.size()
        let xLimit = max(0, ((imageSizeInView.width / 2) * scale) - (maskSize.width / 2))
        let yLimit = max(0, ((imageSizeInView.height / 2) * scale) - (maskSize.height / 2))
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    
    private func calculateBoundedOffset(for proposedOffset: CGSize) -> CGSize {
        let cropFrameSize = cropMode.size()
        // Вычисляем размер изображения с учетом масштаба
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // Вычисляем максимально допустимое смещение с каждой стороны
        let maxOffsetX = max((scaledImageWidth - cropFrameSize.width) / 2, 0)
        let maxOffsetY = max((scaledImageHeight - cropFrameSize.height) / 2, 0)
        
        // Ограничиваем смещение
        let boundedOffsetX = min(max(proposedOffset.width, -maxOffsetX), maxOffsetX)
        let boundedOffsetY = min(max(proposedOffset.height, -maxOffsetY), maxOffsetY)
        
        return CGSize(width: boundedOffsetX, height: boundedOffsetY)
    }
    
    
    // Вычисление минимального масштаба
        private func calculateMinimumScale() -> CGFloat {
            let cropSize = cropMode.size()
            // Предотвращаем деление на ноль
            guard imageSize.width > 0 && imageSize.height > 0 else {
                return 1.0
            }
            
            let minScaleX = cropSize.width / imageSize.width
            let minScaleY = cropSize.height / imageSize.height
            
            // Берем максимальное из двух значений, чтобы изображение
            // полностью покрывало crop рамку
            return max(minScaleX, minScaleY)
        }
    
    // Проверка и корректировка текущего смещения
        private func validateOffset() {
            offset = constrainOffset(offset)
            lastOffset = offset
        }
    
    // Ограничение смещения, чтобы изображение всегда покрывало crop рамку
    private func constrainOffset(_ proposedOffset: CGSize) -> CGSize {
        let cropSize = cropMode.size()
        // Вычисляем текущие размеры изображения с учетом масштаба
        let scaledWidth = imageSize.width * scale
        print("scaledWidth - \(scaledWidth)")
        let scaledHeight = imageSize.height * scale
        print("scaledHeight - \(scaledHeight)")
        // Границы для смещения
        let minX = cropSize.width - scaledWidth
        let maxX: CGFloat = 0
        let minY = cropSize.height - scaledHeight
        let maxY: CGFloat = 0
        print("minX \(minX), minY \(minY)")
        
        // Применяем ограничения
        let constrainedX = min(maxX, max(minX, proposedOffset.width))
        let constrainedY = min(maxY, max(minY, proposedOffset.height))
        
        return CGSize(width: constrainedX, height: constrainedY)
    }
    
    
    
    // Вычисление начального размера изображения после применения aspectRatio
    private func calculateInitialImageSize(cropRect: CGRect) {
        // Вычисляем размер изображения с учетом aspectRatio
        let aspectRatio = image.size.width / image.size.height
        
        // Базовый размер изображения при заполнении
        if cropRect.width / cropRect.height > aspectRatio {
            // Изображение будет расширено по ширине
            imageSize = CGSize(
                width: cropRect.height * aspectRatio,
                height: cropRect.height
            )
        } else {
            // Изображение будет расширено по высоте
            imageSize = CGSize(
                width: cropRect.width,
                height: cropRect.width / aspectRatio
            )
        }
    }
    
    
    private func controlOffset(objectRect: CGRect, cropSize: CGSize, isInteracting: Bool) {
        // Рассчитываем необходимые корректировки смещения
        var newOffset = offset
        
        // Ограничения по X
        if objectRect.minX > 0 {
            // Если объект вышел за левую границу
            newOffset.width -= objectRect.minX
        } else if objectRect.maxX < cropSize.width {
            // Если объект вышел за правую границу
            newOffset.width += cropSize.width - objectRect.maxX
        }
        
        // Ограничения по Y
        if objectRect.minY > 0 {
            // Если объект вышел за верхнюю границу
            newOffset.height -= objectRect.minY
        } else if objectRect.maxY < cropSize.height {
            // Если объект вышел за нижнюю границу
            newOffset.height += cropSize.height - objectRect.maxY
        }
        
        // Применяем новое смещение с анимацией
       // withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
            offset = newOffset
        //}
        
        // Сохраняем последнее смещение, когда перестали взаимодействовать
        if !isInteracting {
            lastOffset = offset
        }
    }
    
    private func scaleGesture() -> some Gesture {
        MagnificationGesture()
            .updating($isInteracting, body: { _, out, _ in
                out = true
            })
            .onChanged({ value in
                let updatedScale = value + lastScale
                scale = (updatedScale < 1 ? 1 : updatedScale)
            })
            .onEnded({ _ in
                if scale < 1 {
                    scale = 1
                    lastScale = 0
                } else {
                    lastScale = scale - 1
                }
            })
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
//            .updating($isInteracting, body: { _, out, _ in
//                out = true
//            })
            .onChanged({ value in
//                offset = CGSize(width: value.translation.width + lastOffset.width,
//                                height: value.translation.height + lastOffset.height)
                
                var newOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                
                let frameSize = cropMode.size()
                
                let scaledSize = CGSize(width: frameSize.width * scale,
                                        height: frameSize.height * scale)

                let delta = CGSize(width: (scaledSize.width - frameSize.width) / 2,
                                   height: (scaledSize.height - frameSize.height) / 2)
                
                let clampedOffset = CGSize(
                    width: min(max(offset.width, -delta.width), delta.width),
                    height: min(max(offset.height, -delta.height), delta.height)
                )

                
                offset = clampedOffset

            })
            .onEnded { _ in
                lastOffset = offset
                //adjustImagePosition(in: cropMode.size())
                //isInteracting = false
            }
    }
    
    private func adjustImagePosition(in cropSize: CGSize) {
          // Получаем границы изображения с учетом масштаба
          let imageWidth = image.size.width * scale
          let imageHeight = image.size.height * scale
          
          // Определяем, насколько изображение может смещаться в каждом направлении
          let horizontalLimit = max(0, (imageWidth - cropSize.width) / 2)
          let verticalLimit = max(0, (imageHeight - cropSize.height) / 2)
          
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
              // Если изображение меньше области кадрирования, центрируем его
              if imageWidth < cropSize.width {
                  offset.width = 0
              } else {
                  // Иначе ограничиваем смещение по горизонтали
                  offset.width = max(-horizontalLimit, min(horizontalLimit, offset.width))
              }
              
              if imageHeight < cropSize.height {
                  offset.height = 0
              } else {
                  // Иначе ограничиваем смещение по вертикали
                  offset.height = max(-verticalLimit, min(verticalLimit, offset.height))
              }
          }
          
          // Обновляем последнее смещение
          lastOffset = offset
      }
    
    
    func grid() -> some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            VStack {
                ForEach(1...8, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
    


    // Эта функция принимает оригинальное изображение, текущий масштаб и смещение в UI
    // и возвращает обрезанное изображение на основе этих параметров
    func cropImage(originalImage: UIImage, scale: CGFloat, offset: CGSize, cropSize: CGSize) -> UIImage? {
        // 1. Получаем размеры оригинального изображения
        let originalSize = originalImage.size
        
        // 2. Рассчитываем реальный масштаб изображения в рамке кропа
        // (учитываем аспект изображения и аспект рамки)
        let imageAspect = originalSize.width / originalSize.height
        let cropAspect = cropSize.width / cropSize.height
        
        // Определяем, как будет масштабироваться изображение в режиме .fill
        let fillScale: CGFloat
        if imageAspect > cropAspect {
            // Изображение шире, чем рамка (заполнится по высоте)
            fillScale = cropSize.height / originalSize.height
        } else {
            // Изображение выше, чем рамка (заполнится по ширине)
            fillScale = cropSize.width / originalSize.width
        }
        
        // 3. Рассчитываем фактический размер, который занимает изображение в рамке без пользовательского масштабирования
        let filledImageSize = CGSize(
            width: originalSize.width * fillScale,
            height: originalSize.height * fillScale
        )
        
        // 4. Учитываем пользовательское масштабирование (scale)
        let scaledImageSize = CGSize(
            width: filledImageSize.width * scale,
            height: filledImageSize.height * scale
        )
        
        // 5. Рассчитываем отношение размера оригинального изображения к текущему размеру на экране
        let originalToDisplayRatio = originalSize.width / scaledImageSize.width
        
        // 6. Рассчитываем центр изображения при отсутствии смещения
        let centeredImageOffset = CGPoint(
            x: (scaledImageSize.width - cropSize.width) / 2,
            y: (scaledImageSize.height - cropSize.height) / 2
        )
        
        // 7. Учитываем пользовательское смещение (offset)
        // Отрицательное смещение в UI означает сдвиг изображения вправо/вниз
        let effectiveOffset = CGPoint(
            x: centeredImageOffset.x - offset.width,
            y: centeredImageOffset.y - offset.height
        )
        
        // 8. Переводим смещение в координаты для оригинального изображения
        let cropX = effectiveOffset.x * originalToDisplayRatio
        let cropY = effectiveOffset.y * originalToDisplayRatio
        
        // 9. Рассчитываем размер области кропа в координатах оригинального изображения
        let cropWidth = cropSize.width * originalToDisplayRatio
        let cropHeight = cropSize.height * originalToDisplayRatio
        
        // 10. Создаем прямоугольник для обрезки
        let cropRect = CGRect(
            x: max(0, cropX),
            y: max(0, cropY),
            width: min(originalSize.width, cropWidth),
            height: min(originalSize.height, cropHeight)
        )
        
        // 11. Выполняем обрезку
        guard let cgImage = originalImage.cgImage,
              let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }

    // Пример использования:
    // let croppedImage = cropImage(originalImage: myImage, scale: currentScale, offset: currentOffset, cropSize: cropFrameSize)
    // где currentOffset имеет тип CGSize

}

//#Preview {
//    CropView(image: UIImage(named: "gotta.JPG")!)
//}


final class Model: ObservableObject {
    @Published var value = 0
    
    static let shared = Model()
}

struct Counter: View {
    @ObservedObject var model: Model
    
    var body: some View {
        Button("Increment: \(model.value)") {
            model.value += 1
        }
    }
}

struct ContentView: View {
    var body: some View {
        Counter(model: Model.shared)
    }
}
