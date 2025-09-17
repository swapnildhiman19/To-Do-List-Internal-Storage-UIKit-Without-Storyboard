//
//  MainCoordinator.swift
//  Todoey
//
//  Created by EasyAiWithSwapnil on 17/09/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit

protocol Coordinator {
    var navigationController : UINavigationController { get set }
    func start()
}

class MainCoordinator : Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = CategoryViewController()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MainCoordinator : CategoryViewControllerDelegate {
    
    func categoryCellTapped(_ category: Category) {
        //opening the specific ToDoListViewController attached to Category
        let vc = ToDoListViewController(selectedCategory : category)
        navigationController.pushViewController(vc, animated: true)
    }
    
}
