//
//  OHNavigatorModifier.swift
//  HSBCOpen
//
//  Created by TQ on 2022/10/25.
//

import SwiftUI

// Interface
public extension View {
    func OH_observeNavigationController() -> some View {
        modifier(OHObserveNavigationControllerModifier())
    }
    
    func OH_observeViewController() -> some View {
        modifier(OHObserveViewControllerModifier())
    }
}

// - MARK: Setup NavigationControllerModifier

struct OHObserveNavigationControllerModifier: ViewModifier {
    @State var navigator: OHNavigator
    
    init() {
        self.navigator = OHNavigator()
    }
    
    func body(content: Content) -> some View {
        content
            .introspectNavigationController { nav in
                self.navigator.addNavController(nav)
            }
            .environment(\.oh_navigator, $navigator)
    }
}

// - MARK: Setup ViewControllerModifier

struct OHObserveViewControllerModifier: ViewModifier {
    @Environment(\.oh_navigator.wrappedValue) var navigator
    
    init() {}
    
    func body(content: Content) -> some View {
        content
            .introspectViewController { vc in
                navigator.addViewController(vc)
            }
    }
}

// - MARK: EnvironmentKey

public struct OHNavigatorKey: EnvironmentKey {
    public static var defaultValue: Binding<OHNavigator> = .constant(OHNavigator())
}

public extension EnvironmentValues {
    var oh_navigator: Binding<OHNavigator> {
        get { self[OHNavigatorKey.self] }
        set { self[OHNavigatorKey.self] = newValue }
    }
}

extension NSNotification {
    static let OHNavigatorUpdateVCIdentifier = Notification.Name(rawValue: "OHNavigatorUpdateVCIdentifier")
}
