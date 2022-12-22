//
//  AppConstants.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import UIKit

//MARK: - AppInfo
struct AppInfo {
    static let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    static let appCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    static var appId = 0
}

//MARK: - AppURLs
struct AppURLs {
    static let baseURL = "https://www.breakingbadapi.com/"
    
    struct Routes {
        static let api = baseURL + "api/"
    }
    
    struct ApiEndPoints {
        static let characters = Routes.api + "characters"
    }
}

//MARK: - DeviceDimensions
struct DeviceDimensions {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
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

//https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#server_error_responses
//Informational responses (100-199)
//Successful responses (200–299)
//Redirection messages (300–399)
//Client error responses (400–499)
//Server error responses (500–599)
enum APIError: Error {
    case InternetNotConnected, UrlNotValid, MapError, InvalidHTTPURLResponse, DataNotReceived,  InformationalError(Int), DecodingError, RedirectionalError(Int), ClientError(ClientErrorsEnum), ServerError(Int), Unknown(Int)
}

enum ClientErrorsEnum: Int {
    case BadRequest = 400, Unauthorized = 401, PaymentRequired = 402, Forbidden = 403, NotFound = 404, MethodNotAllowed = 405, NotAcceptable = 406, URITooLong = 414, Other
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
