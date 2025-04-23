//
//  DependencyContainer.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//

class DependencyContainer {
    // Синглтон или передаваемый через DI объект
    static let shared = DependencyContainer()
    
    // Приватные переменные для хранения сервисов
//    private var networkServiceInstance: NetworkServiceProtocol?
//    private var storageServiceInstance: StorageServiceProtocol?
    
    // Ленивое создание сервисов по запросу
//    func networkService() -> NetworkServiceProtocol {
//        if networkServiceInstance == nil {
//            networkServiceInstance = NetworkService()
//        }
//        return networkServiceInstance!
//    }
    
//    func storageService() -> StorageServiceProtocol {
//        if storageServiceInstance == nil {
//            storageServiceInstance = StorageService()
//        }
//        return storageServiceInstance!
//    }
    
    // Дополнительно: метод очистки для освобождения памяти
//    func resetServices() {
//        networkServiceInstance = nil
//        storageServiceInstance = nil
//    }
}
