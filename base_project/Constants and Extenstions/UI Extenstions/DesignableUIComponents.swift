//
//  DesignableUIComponents.swift
//  base_project
//
//  Created by Pranav Singh on 19/08/22.
//

import UIKit

//https://betterprogramming.pub/what-are-ibdesignable-and-ibinspectable-in-swift-1e3440797d9
@IBDesignable
class CustomView: UIView, CustomUIKitProtocol {
    
    @IBInspectable
    var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
 
@IBDesignable
class CustomCornerRadiusView: CustomView, CustomCornerRadiusUIKitProtocol {
    
    @IBInspectable
    var topLeftRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var topRightRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var bottomLeftRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var bottomRightRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    func applyRadiusMaskFor() {
        let path = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        applyRadiusMaskFor()
    }
}

@IBDesignable
class GradientView: CustomCornerRadiusView, GradientUIKitProtocol {
    
    @IBInspectable
    var startColor: UIColor = .black {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable
    var endColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable
    var startLocation: Double = 0.05 {
        didSet {
            updateLocations()
        }
    }
    
    @IBInspectable
    var endLocation: Double = 0.95 {
        didSet {
            updateLocations()
        }
    }
    
    @IBInspectable
    var horizontalMode: Bool = false {
        didSet {
            updatePoints()
        }
    }
    
    @IBInspectable
    var diagonalMode: Bool = false {
        didSet {
            updatePoints()
        }
    }
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
