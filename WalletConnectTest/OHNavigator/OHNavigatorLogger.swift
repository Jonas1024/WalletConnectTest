//
//  OHNavigatorLogger.swift
//  HSBCOpen
//
//  Created by TQ on 2022/10/31.
//

import Foundation

enum OHNavigatorLoggerLevel: Int, Comparable {
    case none = 0
    case debug = 1
    case info = 2
    case warnning = 3
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

protocol OHNavigatorLoggerDelegate: AnyObject {
    func log(level: OHNavigatorLoggerLevel, msg: String)
}

class OHNavigatorLogger: NSObject {
    static let shared = OHNavigatorLogger()
    private var level: OHNavigatorLoggerLevel = .info
    weak var delegate: OHNavigatorLoggerDelegate?
    
    func setupDelegate(_ delegate: OHNavigatorLoggerDelegate) {
        self.invokeLogger(lv: .info, msg: "[OHNavigator]\(OHLoglevelDescrption(.info)) setupDelegate:  \(delegate)")
        self.delegate = delegate
    }
    
    func setupLevel(_ lv: OHNavigatorLoggerLevel) {
        self.invokeLogger(lv: .info, msg: "[OHNavigator]\(OHLoglevelDescrption(.info)) setupLevel:  \(level) -> \(lv)")
        level = lv
    }
    
    func invokeLogger(lv: OHNavigatorLoggerLevel, msg: String) {
        if lv >= level {
            if self.delegate != nil {
                self.delegate?.log(level: lv, msg: msg)
            } else {
                print("[OHNavigator]\(OHLoglevelDescrption(lv)) \(msg)")
            }
        }
    }
    
    func OHLoglevelDescrption(_ lv: OHNavigatorLoggerLevel) -> String {
        switch lv {
        case .debug:
            return "[DEBUG]"
        case .info:
            return "[INFO]"
        case .warnning:
            return "[WARNNING]"
        default:
            return ""
        }
    }
}
