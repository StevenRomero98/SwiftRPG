//
//  RenderDefaultViewEventListener.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2017/01/23.
//  Copyright © 2017年 兎澤佑. All rights reserved.
//

import Foundation
import SwiftyJSON
import JSONSchema
import SpriteKit
import PromiseKit

class RenderDefaultViewEventListener: EventListener {
    var id: UInt64!
    var delegate: NotifiableFromListener?
    var invoke: EventMethod?
    var listeners: ListenerChain?
    var params: JSON?
    let triggerType: TriggerType
    let executionType: ExecutionType

    required init(params: JSON?, chainListeners listeners: ListenerChain?) throws {
        self.params = params
        self.listeners = listeners
        self.triggerType = .immediate
        self.executionType = .onece
        self.invoke = {
            (sender: GameSceneProtocol?, args: JSON?) -> () in
            _ = firstly {
                sender!.hideAllButtons()
            }.then {
                _ in
                sender!.showDefaultButtons()
            }.always {
                let nextEventListener = InvokeNextEventListener(params: self.params, chainListeners: self.listeners)
                self.delegate?.invoke(self, listener: nextEventListener)
            }
        }
    }

    internal func chain(listeners: ListenerChain) {
        self.listeners = listeners
    }
}

