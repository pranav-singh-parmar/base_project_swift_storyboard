//
//  Extenstions.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import UIKit
import Kingfisher

//MARK: - UIViewController
extension UIViewController {
    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
            return topBarHeight
        }
    }
    
    func getSpinnerForTableView(_ tableView: UITableView) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        return spinner
    }
}

//MARK: - UIBezierPath
extension UIBezierPath {
    
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGFloat, topRightRadius: CGFloat, bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat){
        
        self.init()
        
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if topLeftRadius != 0 {
            path.move(to: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y))
        } else {
            path.move(to: topLeft)
        }
        
        if topRightRadius != 0 {
            path.addLine(to: CGPoint(x: topRight.x - topRightRadius, y: topRight.y))
            path.addArc(tangent1End: topRight, tangent2End: CGPoint(x: topRight.x, y: topRight.y + topRightRadius), radius: topRightRadius)
        }
        else {
            path.addLine(to: topRight)
        }
        
        if bottomRightRadius != 0 {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomRightRadius))
            path.addArc(tangent1End: bottomRight, tangent2End: CGPoint(x: bottomRight.x - bottomRightRadius, y: bottomRight.y), radius: bottomRightRadius)
        }
        else {
            path.addLine(to: bottomRight)
        }
        
        if bottomLeftRadius != 0 {
            path.addLine(to: CGPoint(x: bottomLeft.x + bottomLeftRadius, y: bottomLeft.y))
            path.addArc(tangent1End: bottomLeft, tangent2End: CGPoint(x: bottomLeft.x, y: bottomLeft.y - bottomLeftRadius), radius: bottomLeftRadius)
        }
        else {
            path.addLine(to: bottomLeft)
        }
        
        if topLeftRadius != 0 {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftRadius))
            path.addArc(tangent1End: topLeft, tangent2End: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y), radius: topLeftRadius)
        }
        else {
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        cgPath = path
    }
}

//MARK: - UIImageView
extension UIImageView {
    func showImageFromURLString(_ urlString: String) {
        let url = URL(string: urlString)
        //        let processor = DownsamplingImageProcessor(size: self.bounds.size)
        //                     |> RoundCornerImageProcessor(cornerRadius: 20)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                //.processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Data
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
