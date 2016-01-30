//
//  Extensions.swift
//  RitualPipes
//
//  Created by Christophe Scholly on 29/01/2016.
//  Copyright © 2016 tec. All rights reserved.
//

import UIKit

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMapped)
                do {
                    let dictionary: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                        return dictionary
                    } else {
                        print("Level file '\(filename)' is not valid JSON")
                        return nil
                    }
                } catch {
                    print("Level file '\(filename)' is not valid JSON: \(error)")
                    return nil
                }
                
                
            } catch {
                print("Could not load level file '\(filename)', error: \(error)")
                return nil
            }
            
        } else {
            print("Could not find level file '\(filename)'")
            return nil
        }
    }
}

extension UIColor {
    //convenience initializers
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red:r/255.0, green:g/255.0, blue:b/255.0, alpha:a)
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red:r/255.0, green:g/255.0, blue:b/255.0, alpha:1)
    }
    
    func colorWithHue(newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func colorWithSaturation(newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    
    func colorWithBrightness(newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    
    func colorWithAlpha(newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    
    func colorWithHighlight(highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    
    func colorWithShadow(shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}

extension CGFloat {
    func normalizePixelPerfect() -> CGFloat {
        let s = round(self)
        return (s % 2 == 0) ? s : (s + CGFloat(1))
    }
}
