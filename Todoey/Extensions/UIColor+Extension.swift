//
//  UIColor+Extension.swift
//  Todoey
//
//  Created by EasyAiWithSwapnil on 30/09/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit

extension UIColor {
    // Returns a random color
    static func randomFlat() -> UIColor {
        // You can use any logic you want; here, just a random hue with full sat/bright
        return UIColor(hue: CGFloat.random(in: 0...1), saturation: 0.7, brightness: 0.9, alpha: 1.0)
    }
    
    // Convert UIColor to hex string for persistence
    func toHexString() -> String {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
    
    // Create UIColor from hex string
    static func fromHexString(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") { hexSanitized.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16)/255,
            green: CGFloat((rgb & 0x00FF00) >> 8)/255,
            blue: CGFloat(rgb & 0x0000FF)/255, alpha: 1)
    }
    
    func adjusted(brightness: CGFloat) -> UIColor {
        var h: CGFloat=0, s: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: brightness, alpha: a)
        }
        return self
    }
}
