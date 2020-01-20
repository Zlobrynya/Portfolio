//
//  InfoViewController.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 20/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import RxSwift

class InfoViewController: UIViewController {
    let viewModel = InfoModelView()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let ob = Firebase.getGeneralInfo()
        _ = ob.subscribe{ on in
            print("subscribe  \(on)")
            switch on{
            case .next(let model):
                print(model.FIO)
            case .error(let error):
                print(error)
            case .completed:
                break
            @unknown default:
                break
            }
        }
    }
}
