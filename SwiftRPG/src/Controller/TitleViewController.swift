//
//  TitleViewController.swift
//  SwiftRPG
//
//  Created by 兎澤佑 on 2015/07/15.
//  Copyright (c) 2015年 兎澤佑. All rights reserved.
//

import UIKit
import SpriteKit

class TitleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = TitleScene(frame: self.view.frame)
        view.titleSceneDelegate = self
        
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TitleViewController: TitleSceneDelegate {
    func newGameTouched() {
        let gameViewController: UIViewController = GameViewController()
        self.present(gameViewController, animated: false, completion: nil)
    }
}
