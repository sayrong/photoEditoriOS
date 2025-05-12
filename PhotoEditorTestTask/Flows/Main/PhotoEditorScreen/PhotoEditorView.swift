//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

protocol PhotoEditorCoordinatorDelegate: AnyObject {
    func presentCropper(with image: UIImage, onComplete: @escaping (UIImage?) -> Void)

}

final class PhotoEditorViewModel: ObservableObject {
    
    private weak var delegate: PhotoEditorCoordinatorDelegate?
    
    private var originalImage: UIImage
    private var croppedImage: UIImage?
    
    var editImage: UIImage {
        croppedImage ?? originalImage
    }
    
    @Published var editMode: EditMode?
    @Published var movableImageVM: MovableImageViewModel
    
    init(originalImage: UIImage, delegate: PhotoEditorCoordinatorDelegate?) {
        self.originalImage = originalImage
        self.delegate = delegate
        self.movableImageVM = MovableImageViewModel()
    }
    
    func startCropping() {
        delegate?.presentCropper(with: originalImage,
                                 onComplete: { [weak self] result in
            self?.croppedImage = result
            self?.editMode = nil
            self?.objectWillChange.send()
        })
    }
    
}

enum EditMode: CaseIterable {
    case move
    case filters
    case markup
    case crop
    
    func iconName() -> String {
        switch self {
        case .move:
            "move.3d"
        case .filters:
            "camera.filters"
        case .markup:
            "pencil.tip"
        case .crop:
            "crop"
        }
    }
}

struct PhotoEditorView: View {
    
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
        .onChange(of: viewModel.editMode) { _, newValue in
            if newValue == .crop {
                viewModel.startCropping()
            }
        }
    }
    
    func editControls() -> some View {
        HStack {
            Spacer()
            switch viewModel.editMode {
            case .move:
                MovableImageControls(viewModel: viewModel.movableImageVM)
            case .crop:
                Button {
                    
                } label: {
                    Text("crop")
                }

            case .filters:
                Spacer()
            case .markup:
                Spacer()
            case nil:
                Spacer()
            }
        }
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.black)
    }
    
    func canvas() -> some View {
        ZStack {
            Color.clear //
            MovableImage(image: viewModel.editImage,
                         viewModel: viewModel.movableImageVM)
        }
        .clipped() // обрезает всё, что выходит за пределы
        .contentShape(Rectangle()) // чтобы жесты работали только внутри
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func editModePanel() -> some View {
        HStack(spacing: 10) {
            ForEach(EditMode.allCases, id: \.self) { mode in
                Button {
                    viewModel.editMode = viewModel.editMode == mode ? nil : mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.editMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
}

#Preview {
    PhotoEditorView(viewModel: PhotoEditorViewModel(originalImage: UIImage(named: "gotta.JPG")!, delegate: nil))
}
