//
//  ImagePageVC.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 13/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var nameImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nameImage = nameImage{
            imageView.image = UIImage(named: nameImage)
        }
    }
}
