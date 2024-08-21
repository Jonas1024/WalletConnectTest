//
//  OHNavigationView.swift
//  HSBCOpen
//
//  Created by TQ on 2022/10/25.
//

import SwiftUI

struct OHNavigationView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
        }
        .OH_observeNavigationController()
    }
}

// @Warning: Currently not supported OHNavigationLink tag
// @Warning: Currently not supported OHNavigationLink id
struct OHNavigationLink<Label, Destination>: View where Label: View, Destination: View {
    let destination: Destination
    let label: Label
    var animated: Bool = true
    let isActive: Binding<Bool>?
    var bindingActive: Bool = false
    
    @Environment(\.oh_navigator.wrappedValue) var navigator
    
    public init(@ViewBuilder destination: () -> Destination,
                @ViewBuilder label: () -> Label,
                animated: Bool = true) {
        self.isActive = .constant(false)
        self.destination = destination()
        self.label = label()
        self.animated = animated
        self.bindingActive = false
    }
    
    public init(isActive: Binding<Bool>,
                @ViewBuilder destination: () -> Destination,
                @ViewBuilder label: () -> Label) {
        self.isActive = isActive
        self.destination = destination()
        self.label = label()
        self.bindingActive = true
    }
    
    public init(destination: Destination,
                @ViewBuilder label: () -> Label,
                animated: Bool = true) {
        self.isActive = .constant(false)
        self.destination = destination
        self.label = label()
        self.animated = animated
        self.bindingActive = false
    }
    
    public init(destination: Destination,
                isActive: Binding<Bool>,
                @ViewBuilder label: () -> Label) {
        self.isActive = isActive
        self.destination = destination
        self.label = label()
        self.bindingActive = true
    }
    
    var body: some View {
        if bindingActive {
            // will always use animate:true
            NavigationLink(isActive: isActive!) {
                destination.OH_observeViewController()
            } label: {
                label
            }
        } else {
            // enable animation switch
            Button {
                navigator.pushView({ destination },
                    animated: animated,
                    completion: { success in
                        print("[OHNavigationLink] print result: \(success)")
                    }
                )
            } label: {
                label
            }
        }
    }
}

extension OHNavigationLink {
    var active: Bool {
        return isActive != nil && isActive!.wrappedValue
    }
}
