//
//  Constants.swift
//  base_project
//
//  Created by Pranav Singh on 10/12/23.
//

import Foundation
import UIKit

//MARK: - enums
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
