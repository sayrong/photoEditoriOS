
# 📸 SwiftUI MVVM+C Demo Project

**PhotoEditorTestApp** is a SwiftUI-based demo application that demonstrates a modular architecture using **MVVM+C** (Model-View-ViewModel + Coordinator).  
The app supports photo editing with transformations, cropping, filters, and text stickers — and includes basic authentication.



## 🔧 Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM+C (with Clean Architecture principles)
- **Reactive**: Combine
- **Auth**: Firebase/Auth, Google Sign-In SDK
- **Graphics**: Core Image, PencilKit
- **Code Tools**: SwiftGen, SwiftLint



## ✅ Features

### 🔐 Authentication
- Sign in via Email or Google
- Registration and login form validation
- Password reset functionality

### 🖼 Photo Editing
- Import photo from camera or photo library
- Transformations: **move**, **rotate**, **scale**
- Crop functionality
- Apply Core Image filters
- Add and move editable text stickers
- **Undo/Redo** support with custom state manager
- Export final edited image



## 📲 UI Flow Sketches

<img src="https://github.com/user-attachments/assets/a29da784-dab5-420d-a7e9-71adb16b1cf0" height="250" />
<img src="https://github.com/user-attachments/assets/6a5e3695-b7f7-4531-b0cd-1f7856b5e6b3" height="250" />

<br><br>

## 🛠 Setup

### SwiftGen

Used to generate strongly-typed enums for:
- Assets (e.g. Colors, Images)
- Localizations

SwiftGen is integrated into the **Build Phases**, so code is regenerated automatically on build.
```bash
brew install swiftgen
```

### SwiftLint (Optional)

Used to maintain consistent code style across the project.

```bash
brew install swiftlint
```

Configuration is provided in `.swiftgen.yml` / `.swiftlint.yml` in the project root.

<br><br>

## 🧱 Architecture Overview

This project follows a pragmatic **MVVM+C** (Model-View-ViewModel + Coordinator) architecture, designed to align well with SwiftUI's reactive model.

The codebase is influenced by **SOLID principles** and borrows selective ideas from **Clean Architecture**, while intentionally avoiding unnecessary complexity.

- Responsibilities are split to keep logic manageable and modular.
- `ViewModel` acts as a mediator between the View and the data/services layer. It performs lightweight logic and delegates complex operations to dedicated services.
- Services are injected via protocols to keep modules testable and loosely coupled.
- There’s no strict layering between `Presentation`, `Domain`, and `Data`, but the overall separation is respected conceptually:
  - `View` → UI layer  
  - `ViewModel` → coordination and state management  
  - `Services` → data operations, business logic


## 🧭 Coordinator & Flow Construction

Navigation logic is managed using **Coordinators**, which help decouple view logic from screen flow and transitions.

- Navigation is built on top of `NavigationStack`, with flows modeled hierarchically.
- Coordinators define entry points for each flow and create screens with required dependencies.
- In simple cases, screens are created directly inside the Coordinator.
- When the creation logic grows, it is extracted into a **dedicated Factory** (e.g., `AuthModuleFactory`), which builds views and injects their dependencies.

To keep things modular and testable:
- Factories are defined via protocols
- Dependencies (like `AuthService`) are resolved using a minimal `DependencyContainer`, which caches and lazily instantiates shared services

> This setup avoids full-featured DI frameworks in favor of **lightweight, manual dependency injection**, where control and visibility over the wiring is explicit.

<img src="https://github.com/user-attachments/assets/da9b6535-0401-478b-ae9f-4162b3cba80d" height="400" />



## 📦 SwiftUI Module Structure

Each module generally includes:

- `View` — defines the UI and sends user actions
- `ViewModel` — processes actions, manages state via `@Published`, and communicates with services
- `Services` — handle data operations, encapsulated and abstracted via protocols
- `Models` — simple data representations

🔁 **Flow:**
1. The View triggers actions through the ViewModel  
2. The ViewModel delegates to Services and updates state  
3. State updates trigger UI changes automatically

This setup keeps things lightweight, but can evolve into a stricter Clean Architecture with:
- **UseCases** for business rules
- **Repositories** to abstract data layers

<img src="https://github.com/user-attachments/assets/f70f9e63-c348-42af-a4c9-5d06dc97fc96" height="400" />



## 📁 Project Structure

```
MVVMExample/
├── App/                    # App entry point
├── Flows/                  # Application flows
│   ├── <ModuleName>/       # Each feature module
│   │   ├── Coordinator/     # Handles navigation
│   │   ├── Screen/          # Views + ViewModels
│   │   ├── Models/          # Local models
│   │   └── Services/        # Business logic
│   ├── Extensions/         # Common Swift extensions
│   ├── Models/             # Shared models
│   └── UI/                 # Reusable UI components
```

<br><br>

## 🚀 Status

This is a test/demo project for architecture and photo editing proof-of-concept.
It's designed to be extended further or used as a base for production features.



## 📬 Contact

Feel free to open issues or pull requests if you'd like to contribute or ask questions!
