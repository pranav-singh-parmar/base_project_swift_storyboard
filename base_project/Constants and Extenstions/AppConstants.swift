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
    
    static func getAPIURL() -> String {
        return baseURL + "api/"
    }
}

//MARK: - DeviceDimensions
struct DeviceDimensions {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

//MARK: - enums
typealias JSONKeyPair = [String: Any]

enum HTTPMethod: String {
    case get, post, put, delete
}

enum JsonStructEnum {
    case OnlyModel, OnlyJson, Both
}

enum ParameterEncoding: String {
    case jsonBody, urlFormEncoded, formData
}

//https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#server_error_responses
//Informational responses (100-199)
//Successful responses (200–299)
//Redirection messages (300–399)
//Client error responses (400–499)
//Server error responses (500–599)
enum APIError: Error {
    case internetNotConnected,
         urlNotValid,
         mapError,
         invalidHTTPURLResponse,
         dataNotReceived,
         informationalError(Int),
         decodingError,
         redirectionalError(Int),
         clientError(ClientErrorsEnum),
         serverError(Int),
         unknown(Int)
}

enum ClientErrorsEnum: Int {
    case badRequest = 400,
         unauthorized = 401,
         paymentRequired = 402,
         forbidden = 403,
         notFound = 404,
         methodNotAllowed = 405,
         notAcceptable = 406,
         uriTooLong = 414,
         other
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
