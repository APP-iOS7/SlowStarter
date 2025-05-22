//
//  MeetingDateViewController.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import UIKit

class MeetingDateViewController: UIViewController {

    private let viewModel = MeetingDateViewModel()
    
    private let tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        tabBar.delegate = self
        setupTabBarItems()
    }
    
    private func setupUI() {
//        view.addSubview()
        view.addSubview(tabBar)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 75)
            ])
    }
    
    func setupTabBarItems() {
        var items: [UITabBarItem] = []
        for (index, tabData) in viewModel.tabTitles.enumerated() {
            let image = UIImage(systemName: tabData.tabIcon)
            let item = UITabBarItem(title: tabData.title, image: image, tag: index)
            items.append(item)
        }
        tabBar.setItems(items, animated: false)
    }
}

// MARK: - UITabBarDelegate
extension MeetingDateViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title = item.title else {
            return print("Selected tab: No title")
        }
        print("Selected tab: \(title)")
    }
}

#Preview {
    MeetingDateViewController()
}
