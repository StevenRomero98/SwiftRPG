//
//  EventManager.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2016/08/02.
//  Copyright © 2016年 兎澤佑. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol NotifiableFromDispacher {
    func invoke(_ listener: EventListener)
}

enum EventManagerError: Error {
    case FailedToTrigger(String)
}

class EventManager: NotifiableFromDispacher {
    fileprivate var touchEventDispacher: EventDispatcher
    fileprivate var actionButtonEventDispacher: EventDispatcher
    fileprivate var cyclicEventDispacher: EventDispatcher

    fileprivate var isBlockedBehavior: Bool = false

    init() {
        self.touchEventDispacher = EventDispatcher()
        self.actionButtonEventDispacher = EventDispatcher()
        self.cyclicEventDispacher = EventDispatcher()

        self.touchEventDispacher.delegate = self
        self.actionButtonEventDispacher.delegate = self
        self.cyclicEventDispacher.delegate = self
    }

    @discardableResult
    func add(_ listener: EventListener) -> Bool {
        let listeners = self.getAllListeners()
        if listener.eventObjectId != nil {
            for listener_ in listeners {
                if listener_.eventObjectId == listener.eventObjectId
                && listener_.isBehavior == listener.isBehavior {
                    return false
                }
            }
        }
        let dispacher = self.getDispacherOf(listener.triggerType)
        if dispacher.add(listener) == false {
            return false
        } else {
            return true
        }
    }

    @discardableResult
    func remove(_ id: MapObjectId, sender: GameSceneProtocol? = nil) -> Bool {
        let listeners = self.getAllListeners()
        var targetListener: EventListener? = nil
        var targetDispacher: EventDispatcher? = nil

        for listener in listeners {
            if listener.eventObjectId == id
            && listener.isBehavior == false {
                targetDispacher = self.getDispacherOf(listener.triggerType)
                targetListener = listener
                break
            }
        }

        if let l = targetListener,
           let d = targetDispacher {
            return d.remove(l, sender: sender)
        }

        return false
    }

    func blockBehavior() {
        self.isBlockedBehavior = true
    }

    func unblockBehavior() {
        self.isBlockedBehavior = false
    }

    func trigger(_ type: TriggerType, sender: GameSceneProtocol!, args: JSON!) throws {
        let dispacher = self.getDispacherOf(type)
        do {
            try dispacher.trigger(sender, args: args)
        } catch EventDispacherError.FiledToInvokeListener(let string) {
            throw EventManagerError.FailedToTrigger(string)
        }
    }

    func existsListeners(_ type: TriggerType) -> Bool {
        let dispathcer = self.getDispacherOf(type)
        let listeners = dispathcer.getAllListeners()
        return !listeners.isEmpty
    }

    func shouldActivateButton() -> Bool {
        let listeners = self.getDispacherOf(.immediate).getAllListeners()
        for listener in listeners {
            if let _ = listener as? ActivateButtonListener {
                return true
            }
        }
        return false
    }

    // MARK: - Private methods

    fileprivate func getAllListeners() -> [EventListener] {
        var listeners: [EventListener] = []
        listeners += self.touchEventDispacher.getAllListeners()
        listeners += self.actionButtonEventDispacher.getAllListeners()
        listeners += self.cyclicEventDispacher.getAllListeners()
        return listeners
    }

    fileprivate func getDispacherOf(_ type: TriggerType) -> EventDispatcher {
        switch type {
        case .touch:
            return self.touchEventDispacher
        case .button:
            return self.actionButtonEventDispacher
        case .immediate:
            return self.cyclicEventDispacher
        }
    }

    // MARK: - NotifiableFromDispacher

    // TODO: remove, add が失敗した場合の処理の追加
    func invoke(_ listener: EventListener) {
        let nextListenersDispacher = self.getDispacherOf(listener.triggerType)

        if isBlockedBehavior && listener.isBehavior {
            return
        }

        if !nextListenersDispacher.add(listener) {
            print("Failed to add listener" )
        }
    }
}
