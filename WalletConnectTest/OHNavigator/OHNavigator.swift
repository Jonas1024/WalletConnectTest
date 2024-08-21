//
//  OHNavigator.swift
//  HSBCOpen
//
//  Created by TQ on 2022/10/25.
//

import Foundation
import SwiftUI

/*
 
 @Description: A framework for managing the NavigationView/NavigationLink.
 However, if you use iOS 16+, we recommend you to use NavigationStack.
 
 All you need to do:
 1. Use OHNavigationView instead of NavigationView
 (Warning: We do not recommend using multiple layers of NavigationView.)
 2. Use OHNavigationLink instead of NavigationLink
 
 After that, you can access the environment object wherever you want.
 Like this:
 @Environment(\.oh_navigator.wrappedValue) var navigator
 
 And you can use the interfaces below.
 - navigator.pushView(View, animated, completion)
 - navigator.popToRoot(animated, completion)
 - navigator.popView(vcId, animated, completion)
 - navigator.popView(index, animated, completion)
 - navigator.numOfItems -> Int // count of view controllers

 @Example:
 Use Button to jump page manually:
     Button {
         navigator.pushView(animated: true) {
             // do sth
         }
     } label: {
     }
 
 Furthermore: you can also use OHNavigatorLogger.
 To achive that, you need to implement the OHNavigatorLoggerDelegate, and
 setup delegate using `OHNavigatorLogger.shared.setupDelegate`, also you can use
 `OHNavigatorLogger.shared.setupLevel` to setup logger level.
 @Example: see OHNavigatorLoggerInstance.swift
 
*/

public class OHNavigator {
    var nav: UINavigationController?
    var vcIds: [String] = []
    
    func addNavController(_ navi: UINavigationController) {
        nav = navi
        
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "add new navigation \(navi).")
        
        let vc: UIViewController = navi.topViewController!
        addViewController(vc)
    }
    
    func addViewController(_ vc: UIViewController) {
        if hasContainerId(vc.ohViewControllerId ?? "") {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "fail to add vc \(vc) because already exists.")
            return
        }
        
        vc.ohViewControllerId = UUID().uuidString
        
        var containers: [String] = vcIds
        containers.append(vc.ohViewControllerId!)
        vcIds = containers
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to add vc \(vc.ohViewControllerId!).")
        printNow()
        
        NotificationCenter.default.post(
            name: NSNotification.OHNavigatorUpdateVCIdentifier,
            object: nil,
            userInfo: ["viewController": vc])
        
        OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "success send NSNotification.OHNavigatorUpdateVCIdentifier.")
    }
    
    private func removeViewController(_ viewControllerIds: [String]) {
        if viewControllerIds.count <= 0 {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "fail to remove empty vcIds.")
            return
        }
        
        var containers: [String] = vcIds
        if containers.count > 0 {
            containers.removeAll { obj in
                return viewControllerIds.contains(obj)
            }
            vcIds = containers
        }
        
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to remove vcIds \(viewControllerIds).")
        printNow()
    }
    
    public func numOfItems() -> Int {
        return vcIds.count
    }
    
    public func topViewControllerId() -> String {
        return vcIds.count > 0 ? vcIds[vcIds.count - 1] : ""
    }
    
    private func hasContainerId(_ vcId: String) -> Bool {
        if vcId.count <= 0 {
            return false
        }
        
        return vcIds.contains(vcId)
    }
    
    // @dropAllFromRoot: automatically drop all the viewControllers between root and destination.
    public func pushView<V: View>(@ViewBuilder _ view: () -> V,
                                  animated: Bool = true,
                                  dropAllFromRoot: Bool = false,
                                  completion: @escaping (_ finish: Bool) -> Void = { _ in }) {
        let vc: UIViewController = UIHostingController(rootView: view().OH_observeViewController())
        
        nav!.pushViewController(vc, animated: animated)
        
        if dropAllFromRoot {
            let vcs: [UIViewController] = nav!.viewControllers
            var newVCs: [UIViewController] = [vcs.first!]
            if vcs.count > 1 {
                newVCs.append(vcs.last!)
            }
            
            nav!.viewControllers = newVCs
            // vcIds will add current vc later after OH_observeViewController
            vcIds = [vcIds.first!]
        }
        
        // The system pop animation time is about 0.25s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion(true)
        }
        
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to push view, now: \(vc).")
        printNow()
    }
    
    public func popToRoot(animated: Bool = true,
                          completion: @escaping (_ finish: Bool) -> Void = { _ in }) {
        nav!.popToRootViewController(animated: animated)
        vcIds = Array(vcIds.prefix(1))
        
        // The system pop animation time is about 0.25s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion(true)
        }
        
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to pop to root.")
        printNow()
    }
    
    public func popView(vcId: String,
                        animated: Bool = true,
                        completion: @escaping (_ finish: Bool) -> Void = { _ in }) {
        if vcId.count <= 0 {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "require vcId to popView.")
            assert(false, "")
            completion(false)
            return
        }
        
        let vcs: [UIViewController] = nav!.viewControllers
        var found: Bool = false
        for vc in vcs.reversed() where vc.ohViewControllerId == vcId {
            found = true
            removeViewControllerAfterPop(vcs: vcs, vcId: vcId)
            nav!.popToViewController(vc, animated: animated)
            
            // The system pop animation time is about 0.25s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                completion(true)
            }
            
            OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to pop vc \(String(describing: vc.ohViewControllerId)).")
            printNow()
            break
        }
        
        if !found {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "fail to pop vc \(vcId).")
        }
    }
    
    public func popView(index: Int,
                        animated: Bool = true,
                        completion: @escaping (_ finish: Bool) -> Void = { _ in }) {
        if index < 0 {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "require index to popView.")
            assert(false, "")
            completion(false)
            return
        }
        
        let vcs: [UIViewController] = nav!.viewControllers
        
        if index >= vcs.count - 1 {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "fail to pop vc with index \(index), because nav.viewControllers count is not enough \(vcs.count).")
            completion(false)
            return
        }
        
        let checkVC: UIViewController? = vcs[index]
        guard let target = checkVC else {
            OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "count not find vcIndex:\(index) in popView.")
            completion(false)
            return
        }
        
        removeViewControllerAfterPop(vcs: vcs, index: index)
        nav!.popToViewController(target, animated: animated)
        
        // The system pop animation time is about 0.25s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion(true)
        }
        
        OHNavigatorLogger.shared.invokeLogger(lv: .info, msg: "success to pop vc \(String(describing: target.ohViewControllerId)).")
        printNow()
    }
    
    private func removeViewControllerAfterPop(vcs: [UIViewController], vcId: String = "") {
        var removeVCIds: [String] = []
        for vc in vcs.reversed() {
            guard let checkVCID = vc.ohViewControllerId else {
                return
            }
            
            if checkVCID == vcId {
                break
            }
            
            removeVCIds.append(checkVCID)
        }
        removeViewController(removeVCIds)
    }
    
    private func removeViewControllerAfterPop(vcs: [UIViewController], index: Int) {
        var removeVCIds: [String] = []
        for i in index+1...vcs.count-1 {
            let item: UIViewController = vcs[i]
            guard let checkVCID = item.ohViewControllerId else {
                continue
            }
            
            removeVCIds.append(checkVCID)
        }
        removeViewController(removeVCIds)
    }
    
    private func printNow() {
        OHNavigatorLogger.shared.invokeLogger(lv: .debug, msg: "now: \(nav!.viewControllers.count) / \(String(describing: vcIds)).")
    }
}

public extension UINavigationController {
    private struct AssociatedKeys {
        static var ohNavigationId = "ohNavigationId"
    }
    
    var ohNavigationId: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ohNavigationId) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ohNavigationId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

public extension UIViewController {
    private struct AssociatedKeys {
        static var ohViewControllerId = "ohViewControllerId"
    }
    
    var ohViewControllerId: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ohViewControllerId) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ohViewControllerId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
