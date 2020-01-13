//
//  ImagesPageVC.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 13/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit

class ImagesPageVC: CustomPageView {
    var nameImages = [String](){
        didSet{
            orderedViewControllers = createImageView()
            if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
            customDelegate?.customPageViewController(customPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    func createImageView() -> [UIViewController]{
        var pages = [UIViewController]()
        for nameImage in nameImages{
            pages.append(newViewController(nameImage: nameImage))
        }
        return pages
    }
    
    private func newViewController(nameImage: String) -> UIViewController {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageVC{
            vc.nameImage = nameImage
            return vc
        }
        return UIViewController()
    }
}
