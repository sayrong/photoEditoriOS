//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

struct PhotoEditorView: View {
    
    enum EditMode: CaseIterable {
        case move
        case crop
        case filters
        case markup
        
        func iconName() -> String {
            switch self {
            case .move:
                "move.3d"
            case .crop:
                "crop"
            case .filters:
                "camera.filters"
            case .markup:
                "pencil.tip"
            }
        }
    }
    
    var image: UIImage
    @StateObject var movableImageVM: MovableImageViewModel
    
    @State var editMode: EditMode?
    
    init(image: UIImage) {
        self.image = image
        _movableImageVM = StateObject(wrappedValue: MovableImageViewModel(image: image))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
    }
    
    func editControls() -> some View {
        HStack {
            Spacer()
            switch editMode {
            case .move:
                MovableImageControls(viewModel: movableImageVM)
            case .crop:
                Spacer()
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
            MovableImage(viewModel: movableImageVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func editModePanel() -> some View {
        HStack(spacing: 10) {
            ForEach(EditMode.allCases, id: \.self) { mode in
                Button {
                    editMode = editMode == mode ? nil : mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(editMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
}

#Preview {
    PhotoEditorView(image: UIImage(systemName: "arrow.clockwise.icloud")!)
}
