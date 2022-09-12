//
//  UIKitProtocols.swift
//  base_project
//
//  Created by Pranav Singh on 12/09/22.
//

import UIKit

protocol CustomUIKitProtocol {
    var cornerRadius: CGFloat { get set }
    var borderWidth: CGFloat { get set }
    var borderColor: UIColor? { get set }
    var shadowRadius: CGFloat { get set }
    var shadowOpacity: Float { get set }
    var shadowOffset: CGSize { get set }
    var shadowColor: UIColor? { get set }
}


protocol CustomCornerRadiusUIKitProtocol {
    var topLeftRadius: CGFloat { get set }
    var topRightRadius: CGFloat { get set }
    var bottomLeftRadius: CGFloat { get set }
    var bottomRightRadius: CGFloat { get set }
    func applyRadiusMaskFor()
}

protocol GradientUIKitProtocol {
//    var startColor: UIColor { set }
//    var endColor: UIColor { set }
//        
//    var startLocation: Double { set }
//    
//    var endLocation: Double { set }
//    
//    var horizontalMode: Bool { set }
//    
//    var diagonalMode: Bool { set }
//    
//    override public class var layerClass: AnyClass { CAGradientLayer.self }
//
//    var gradientLayer: CAGradientLayer

    func updatePoints()
    func updateLocations()
    func updateColors()
}

