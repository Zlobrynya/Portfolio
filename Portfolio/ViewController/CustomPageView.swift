//
//  MainTutorialViewController.swift
//  Steps
//
//  Created by Nikitin Nikita on 13/09/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//

import UIKit

protocol CustomPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter customPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func customPageViewController(customPageViewController: UIPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter customPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func customPageViewController(customPageViewController: UIPageViewController,
                                    didUpdatePageIndex index: Int)
    
}

class CustomPageView: UIPageViewController {
    
    weak var customDelegate: CustomPageViewControllerDelegate?
    
    lazy var orderedViewControllers: [UIViewController] = createCustomVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    func createCustomVC() -> [UIViewController]{
        return [UIViewController]()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyCustomDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyCustomDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            customDelegate?.customPageViewController(customPageViewController: self, didUpdatePageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource
extension CustomPageView: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        notifyCustomDelegateOfNewIndex()
        return orderedViewControllers[previousIndex]
    }
    
    @objc func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount > nextIndex else {
            print("orderedViewControllersCount > nextIndex")
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

extension CustomPageView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyCustomDelegateOfNewIndex()
    }
    
}
