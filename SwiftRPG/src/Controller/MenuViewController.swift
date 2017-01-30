//
//  MenuViewController.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2016/12/21.
//  Copyright © 2016年 兎澤佑. All rights reserved.
//

import UIKit
import SpriteKit

class MenuViewController: UIViewController {
    var viewInitiated: Bool = false
    var scene: SKScene!
    fileprivate var model: MenuSceneModel!
    let transition = TransitionBetweenGameAndMenuSceneAnimator()

    override func loadView() {
        self.view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if (!viewInitiated) {
            self.initializeScene()

            self.view = self.scene.view
            let view = self.view as! SKView
            view.presentScene(self.scene)

            self.viewInitiated = true
        }
    }

    func initializeScene() {
        let scene = MenuScene(size: self.view.bounds.size)
        scene.menuSceneDelegate = self

        self.model = MenuSceneModel()
        self.model.delegate = scene
        self.model.updateItems()
        scene.model = self.model

        self.scene = scene
    }
}

extension MenuViewController: MenuSceneDelegate {
    func didPressBackButton() {
        self.dismiss(animated: true, completion: nil)
    }

    func didSelectedItem(_ indexPath: IndexPath) {
        self.model.selectItem(indexPath)
    }
}

extension MenuViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning?
    {
        self.transition.originFrame = self.view.frame
        self.transition.presenting = true
        return self.transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transition.presenting = false
        return self.transition
    }
}
