//
//  AppConstants.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import UIKit

struct AppConstants {
    
    static let baseURL = "https://www.breakingbadapi.com/"
    static let dimensions = UIScreen.main.bounds.size
    
    //MARK: - AppInfo
    struct AppInfo {
        static let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        static let appCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        static var appId = 0
    }
    
    //MARK: - DeviceDimensions
    struct DeviceDimensions {
        static let width = dimensions.width
        static let height = dimensions.height
    }
    
    //MARK: - AppURLs
    struct AppURLs {
        static let apiURL = baseURL + "api/"
    }
    
    //MARK: - ApiEndPoints
    struct ApiEndPoints {
        static let characters = AppURLs.apiURL + "characters"
    }
}

//MARK: - enums
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum ParameterEncoding {
    case None, QueryParameters, JsonBody, URLFormEncoded, FormData
}

enum JsonStructEnum {
    case OnlyModel, OnlyJson, Both
}

enum ApiStatus {
    case NotHitOnce, IsBeingHit, ApiHit, ApiHitWithError
}

enum FontEnum {
    case Light, Regular, Medium, SemiBold, Bold
}

//MARK: - UIColor
extension UIColor {
    static let blackColor = UIColor(named: "blackColor") ?? UIColor.clear
    static let blackColorForAllModes = UIColor(named: "blackColorForAllModes") ?? UIColor.clear
    static let whiteColor = UIColor(named: "whiteColor") ?? UIColor.clear
    static let whiteColorForAllModes = UIColor(named: "whiteColorForAllModes") ?? UIColor.clear
    
    static let defaultLightGray = UIColor(named: "defaultLightGray") ?? UIColor.clear
    static let shimmerColor = UIColor(named: "shimmerColor") ?? UIColor.clear
}

//MARK: - UIFont
extension UIFont {
    static func bitterLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Light", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Medium", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func bitterBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Bitter-Bold", size: size) ?? .systemFont(ofSize: size)
    }
}
