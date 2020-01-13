//
//  ARVerticalVC.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 13/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit

class ARVerticalVC: ParentArVC {
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    @IBOutlet weak var heightBottomViewLayout: NSLayoutConstraint!
    @IBOutlet weak var buttonOpenClose: UIButton!
    @IBOutlet weak var pageView: UIView!
    
    private var isBottomViewOpen = false
    private var vcPageView: ImagesPageVC?
    private var arrayImage =  ["image1","image2","image3","image4"]
    
    override var isSelectNode: Bool {
        didSet{
            pageView.isHidden = !isSelectNode
            buttonOpenClose.isHidden = !isSelectNode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planeDetection = .vertical
        nameNode = "art.scnassets/frame.scn"
        scaleNode = 1
        countMaxModel = 1
        setUpSceneView()
        vcPageView?.nameImages = arrayImage
        vcPageView?.customDelegate = self
        // Do any additional setup after loading the view.
        if let image = UIImage(named: arrayImage[0]){
            selectNode?.changeTexture(texture: image, nameNode: "Rectangle003", nameMaterial: "Poster_001")
        }
    }
    
    @IBAction func setImageToPoster(_ sender: Any) {
        if let selectNode = selectNode,
            let image = UIImage(named: "image1"){
            selectNode.changeTexture(texture: image, nameNode: "Rectangle003", nameMaterial: "Poster_001")
        }
    }
    
    @IBAction func showBottomPageView(_ sender: Any) {
        bottomLayout.constant = isBottomViewOpen ? CGFloat(heightBottomViewLayout.constant - 15) : CGFloat(0)
        let titleButton = isBottomViewOpen ? "Open" : "Close"
        buttonOpenClose.setTitle(titleButton, for: .normal)
        isBottomViewOpen = !isBottomViewOpen
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let customPageViewController = segue.destination as? ImagesPageVC {
            vcPageView = customPageViewController
        }
    }
    
    override func tapNode(_ recognizer: UITapGestureRecognizer){
        super.tapNode(recognizer)
//        if !(sceneNode[0].node.name?.isEmpty ?? true),
//            let image = UIImage(named: "image1"){
//            sceneNode[0].changeTexture(texture: image, nameNode: "Rectangle003", nameMaterial: "Poster_001")
//        }
    }
}

extension ARVerticalVC: CustomPageViewControllerDelegate{
    func customPageViewController(customPageViewController: UIPageViewController, didUpdatePageCount count: Int) {}
    
    func customPageViewController(customPageViewController: UIPageViewController, didUpdatePageIndex index: Int) {
        if let selectNode = selectNode,
            let image = UIImage(named: arrayImage[index]){
            selectNode.changeTexture(texture: image, nameNode: "Rectangle003", nameMaterial: "Poster_001")
        }
    }
}
