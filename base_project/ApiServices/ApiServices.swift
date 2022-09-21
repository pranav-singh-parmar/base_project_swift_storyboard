//
//  ApiServices.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import Network

class ApiServices {
    func getQueryItems(urlString: String, params: [String: Any]) -> URLComponents? {
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = []
        for (keyName, value) in params {
            urlComponents?.queryItems?.append(URLQueryItem(name: keyName, value: "\(value)"))
        }
        if let component = urlComponents {
            //https://stackoverflow.com/questions/27723912/swift-get-request-with-parameters
            //this code is added because some servers interpret '+' as space becuase of x-www-form-urlencoded specification
            //so we have to percent escape it manually because URLComponents does not perform it
            //space is percent encoded as %20 and '+' is encoded as "%2B"
            urlComponents?.percentEncodedQuery = component.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
        return urlComponents
    }
    
    func getURLRequest(httpMethod: HTTPMethod, urlString: String, isAuthApi: Bool, parameterEncoding: ParameterEncoding, params: [String: Any]?, imageModel: [ImageModel]?) -> URLRequest? {
        
        var urlRequest: URLRequest?
        
        switch parameterEncoding {
        case .None:
            if let url = URL(string: urlString) {
                urlRequest = URLRequest(url: url)
            }
        case .QueryParameters:
            if let params = params {
                let urlComponents = getQueryItems(urlString: urlString, params: params)
                if let url = urlComponents?.url {
                    urlRequest = URLRequest(url: url)
                }
            } else if let url = URL(string: urlString) {
                urlRequest = URLRequest(url: url)
            }
        case .JsonBody:
            if let url = URL(string: urlString) {
                urlRequest = URLRequest(url: url)
                if let params = params {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                        urlRequest?.httpBody = jsonData
                        urlRequest?.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    } catch {
                        print("error in \(urlString)", error.localizedDescription)
                    }
                }
            }
        case .URLFormEncoded:
            if let url = URL(string: urlString) {
                urlRequest = URLRequest(url: url)
                if let params = params {
                    let urlComponents = getQueryItems(urlString: urlString, params: params)
                    let formEncodedString = urlComponents?.percentEncodedQuery
                    if let formEncodedData = formEncodedString?.data(using: .utf8) {
                        urlRequest?.httpBody = formEncodedData
                        urlRequest?.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    } else {
                        print("error in \(urlString) not able to process URLFormEncoded")
                    }
                }
            }
        case .FormData:
            //https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift
            //https://orjpap.github.io/swift/http/ios/urlsession/2021/04/26/Multipart-Form-Requests.html
            //https://bhuvaneswarikittappa.medium.com/upload-image-to-server-using-multipart-form-data-in-ios-swift-5c4eb6de26e2
            if let url = URL(string: urlString) {
                urlRequest = URLRequest(url: url)
                
                let boundary = "Boundary-\(UUID().uuidString)"
                let lineBreak = "\r\n"
                
                var body = Data()
                
                if let params = params {
                    for (key, value) in params {
                        if let params = value as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                            body.appendString("--\(boundary + lineBreak)")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                            //body.appendString("Content-Type: application/json;charset=utf-8\(lineBreak + lineBreak)")
                            body.append(data)
                            body.appendString(lineBreak)
                        } else if let data = "\(value)".data(using: .utf8) {
                            body.appendString("--\(boundary + lineBreak)")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                            //body.appendString("Content-Type: text/plain;charset=utf-8\(lineBreak + lineBreak)")
                            body.append(data)
                            body.appendString(lineBreak)
                        }
                    }
                }
                
                if let imageModel = imageModel {
                    for image in imageModel {
                        body.appendString("--\(boundary + lineBreak)")
                        body.appendString("Content-Disposition: form-data; name=\"\(image.fileKeyName)\"; filename=\"\(image.fileName)\"\(lineBreak)")
                        body.appendString("Content-Type: \(image.mimeType + lineBreak + lineBreak)")
                        body.append(image.file)
                        body.appendString(lineBreak)
                    }
                }
                
                body.appendString("--\(boundary)--\(lineBreak)")
                
                urlRequest?.httpBody = body
                urlRequest?.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                urlRequest?.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            }
        }
        
        urlRequest?.httpMethod = httpMethod.rawValue
        
        //set headers
        urlRequest?.addValue("iOS", forHTTPHeaderField: "device")
        urlRequest?.addValue("application/json", forHTTPHeaderField: "Accept")
        //urlRequest?.addValue("token", forHTTPHeaderField: "Authorization")
        
        print("url", urlRequest?.url?.absoluteString ?? "url not set")
        print("http method is", urlRequest?.httpMethod ?? "http method not assigned")
        print("headers are", urlRequest?.allHTTPHeaderFields ?? [:])
        print("paramenterEncoding is", parameterEncoding)
        print("http body data", urlRequest?.httpBody ?? Data())
        print("params are", params ?? [:])
        
        return urlRequest
    }
    
    func hitApi<T: Decodable>(httpMethod: HTTPMethod, urlString: String, isAuthApi: Bool = false, parameterEncoding: ParameterEncoding = .None, params : [String: Any]? = nil, imageModel: [ImageModel]? = nil, returnRequired: JsonStructEnum = JsonStructEnum.OnlyModel, decodingStruct: T.Type, outputBlockForSucess: @escaping (_ receivedData: T?,_ jsonData: AnyObject?) -> Void, outputBlockForInternetNotConnected: @escaping () -> Void) {
        
//        if Singleton.sharedInstance.internetConnectivity.isConnectedToInternet {
            
            if let urlRequest = getURLRequest(httpMethod: httpMethod, urlString: urlString, isAuthApi: isAuthApi, parameterEncoding: parameterEncoding, params: params, imageModel: imageModel) {
                
                URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    
                    if let _ = error {
                        self.printApiError(.MapError, inUrl: urlString)
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else{
                        self.printApiError(.InvalidHTTPURLResponse, inUrl: urlString)
                        return
                    }
                    
                    guard let data = data else{
                        self.printApiError(.DataNotReceived, inUrl: urlString)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let jsonConvert = try? JSONSerialization.jsonObject(with: data, options: [])
                        let json = jsonConvert as AnyObject
                        
                        switch response.statusCode {
                        case 100...199:
                            self.printApiError(.InformationalError(response.statusCode), inUrl: urlString)
                        case 200...299:
                            switch returnRequired {
                            case .OnlyModel, .Both:
                                do {
                                    // let jsonData = try JSONSerialization.data(withJSONObject: json as AnyObject, options: .prettyPrinted)
                                    // let data = try JSONDecoder().decode(decodingStruct.self, from: jsonData)
                                    let model = try JSONDecoder().decode(decodingStruct.self, from: data)
                                    if returnRequired == JsonStructEnum.Both {
                                        outputBlockForSucess(model, json as AnyObject)
                                    }else{
                                        outputBlockForSucess(model, nil)
                                    }
                                    //added return here if not added here then outblock with nil, nil will be excecuted
                                    return
                                } catch {
                                    self.printApiError(.DecodingError, inUrl: urlString)
                                }
                            case .OnlyJson:
                                outputBlockForSucess(nil, json as AnyObject)
                                //added return here if not added here then outblock with nil, nil will be excecuted
                                return
                            }
                        case 300...399:
                            self.printApiError(.RedirectionalError(response.statusCode), inUrl: urlString)
                        case 400...499:
                            let clientErrorEnum = ClientErrorsEnum(rawValue: response.statusCode) ?? .Other
                            switch clientErrorEnum {
                            case .Unauthorized:
                                Singleton.sharedInstance.alerts.handle401StatueCode()
                            case .BadRequest, .PaymentRequired, .Forbidden, .Required, .NotFound, .MethodNotAllowed, .URITooLong, .Other:
                                if let message = json["message"] as? String {
                                    Singleton.sharedInstance.alerts.errorAlert(message: message)
                                } else if let errorMessage = json["error"] as? String {
                                    Singleton.sharedInstance.alerts.errorAlert(message: errorMessage)
                                } else if let errorMessages = json["error"] as? [String] {
                                    var errorMessage = ""
                                    for message in errorMessages {
                                        if errorMessage != "" {
                                            errorMessage = errorMessage + ", "
                                        }
                                        errorMessage = errorMessage + message
                                    }
                                    Singleton.sharedInstance.alerts.errorAlert(message: errorMessage)
                                } else{
                                    Singleton.sharedInstance.alerts.errorAlert(message: "Server Error")
                                }
                            }
                            self.printApiError(.ClientError(clientErrorEnum), inUrl: urlString)
                        case 500...599:
                            self.printApiError(.ServerError(response.statusCode), inUrl: urlString)
                        default:
                            self.printApiError(.Unknown(response.statusCode), inUrl: urlString)
                            break
                        }
                        //added so that the screen updates even receiving an error
                        outputBlockForSucess(nil, nil)
                    }
                }.resume()
            } else {
                self.printApiError(.UrlNotValid, inUrl: urlString)
            }
//        } else {
//            let monitor = NWPathMonitor()
//            let queue = DispatchQueue(label: urlString)
//            monitor.pathUpdateHandler = { path in
//                DispatchQueue.main.async {
//                    if path.status == .satisfied {
//                        outputBlockForInternetNotConnected()
//                        monitor.cancel()
//                    }
//                }
//            }
//            monitor.start(queue: queue)
//            self.printApiError(.InternetNotConnected, inUrl: urlString)
//        }
    }
    
    private func printApiError(_ apiError: APIError, inUrl urlString: String) {
        print("in api \(urlString) \(apiError)")
    }
}
