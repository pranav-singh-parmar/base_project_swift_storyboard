//
//  ApiServices.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import Network

class ApiServices {
    func getQueryItems(forURLString urlString: String,
                       withParameters params: [String: Any]) -> URLComponents? {
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
    
    func getURL(ofHTTPMethod httpMethod: HTTPMethod,
                forAppEndpoint appEndpoint: AppEndpoints,
                withQueryParameters queryParameters: JSONKeyPair?) -> URLRequest? {
        return getURL(ofHTTPMethod: httpMethod, forString: appEndpoint.getURLString(), withQueryParameters: queryParameters)
    }
    
    func getURL(ofHTTPMethod httpMethod: HTTPMethod,
                forAppEndpoint appEndpoint: AppEndpointsWithParamters,
                withQueryParameters queryParameters: JSONKeyPair?) -> URLRequest? {
        return getURL(ofHTTPMethod: httpMethod, forString: appEndpoint.getURLString(), withQueryParameters: queryParameters)
    }
    
    private func getURL(ofHTTPMethod httpMethod: HTTPMethod,
                        forString urlString: String,
                        withQueryParameters queryParameters: JSONKeyPair?) -> URLRequest? {
        var urlRequest: URLRequest? = nil
        if let queryParameters {
            let urlComponents = getQueryItems(forURLString: urlString,
                                              withParameters: queryParameters)
            if let url = urlComponents?.url {
                urlRequest = URLRequest(url: url)
            }
        } else if let url = URL(string: urlString) {
            urlRequest = URLRequest(url: url)
        }
        urlRequest?.httpMethod = httpMethod.rawValue
        print("\nurl", urlRequest?.url?.absoluteString ?? "URL not set for \(urlString)")
        print("http method is", urlRequest?.httpMethod ?? "http method not assigned")
        return urlRequest
    }
    
    func hitApi<T: Decodable>(withURLRequest urlRequest: URLRequest?,
                              decodingStruct: T.Type,
                              returnRequired: JsonStructEnum = JsonStructEnum.OnlyModel,
                              outputBlockForSucess: @escaping (_ receivedData: T?,_ jsonData: AnyObject?) -> Void,
                              outputBlockForInternetNotConnected: @escaping () -> Void) {
        
        let urlString = urlRequest?.url?.absoluteString ?? "URL not set"
        if Singleton.sharedInstance.internetConnectivity.isConnectedToInternet {
            
            if let urlRequest {
                
                URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    
                    guard error == nil else {
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
                        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                        let json = jsonObject as AnyObject
                        
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
                                } catch let DecodingError.typeMismatch(type, context) {
                                    print("Type '\(type)' mismatch:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                    self.printApiError(.DecodingError, inUrl: urlString)
                                } catch let DecodingError.keyNotFound(key, context) {
                                    print("Key '\(key)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                    self.printApiError(.DecodingError, inUrl: urlString)
                                } catch let DecodingError.valueNotFound(value, context) {
                                    print("Value '\(value)' not found:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                    self.printApiError(.DecodingError, inUrl: urlString)
                                } catch let DecodingError.dataCorrupted(context) {
                                    print("Data Corrupted:", context.debugDescription)
                                    print("codingPath:", context.codingPath)
                                    self.printApiError(.DecodingError, inUrl: urlString)
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
                            case .BadRequest, .PaymentRequired, .Forbidden, .NotFound, .MethodNotAllowed, .NotAcceptable, .URITooLong, .Other:
                                if let message = json["message"] as? String {
                                    Singleton.sharedInstance.alerts.errorAlertWith(message: message)
                                } else if let errorMessage = json["error"] as? String {
                                    Singleton.sharedInstance.alerts.errorAlertWith(message: errorMessage)
                                } else if let errorMessages = json["error"] as? [String] {
                                    var errorMessage = ""
                                    for message in errorMessages {
                                        if errorMessage != "" {
                                            errorMessage = errorMessage + ", "
                                        }
                                        errorMessage = errorMessage + message
                                    }
                                    Singleton.sharedInstance.alerts.errorAlertWith(message: errorMessage)
                                } else{
                                    Singleton.sharedInstance.alerts.errorAlertWith(message: "Server Error")
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
        } else {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: urlString)
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    if path.status == .satisfied {
                        outputBlockForInternetNotConnected()
                        monitor.cancel()
                    }
                }
            }
            monitor.start(queue: queue)
            self.printApiError(.InternetNotConnected, inUrl: urlString)
        }
    }
    
    private func printApiError(_ apiError: APIError, inUrl urlString: String) {
        print("in api \(urlString) \(apiError)")
    }
}

extension URLRequest {
    mutating func addHeaders(_ headers: JSONKeyPair? = nil, shouldAddAuthToken: Bool = false) {
        //set headers
        self.addValue("iOS", forHTTPHeaderField: "device")
        self.addValue("application/json", forHTTPHeaderField: "Accept")
        if shouldAddAuthToken {
            //urlRequest?.addValue("token", forHTTPHeaderField: "Authorization")
        }
        
        if let headers {
            headers.forEach { key, value in
                self.addValue(key, forHTTPHeaderField: "\(value)")
            }
        }
    }
    
    mutating func addParameters(_ parameters: JSONKeyPair?,
                                withFileModel fileModel: [FileModel]? = nil,
                                as parameterEncoding: ParameterEncoding) {
        let urlString = self.url?.absoluteString ?? ""
        switch parameterEncoding {
        case .jsonBody:
            if let parameters {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters,
                                                              options: .prettyPrinted)
                    self.httpBody = jsonData
                    self.addValue("application/json",
                                  forHTTPHeaderField: "Content-Type")
                } catch {
                    print("error in \(urlString) with parameterEncoding \(parameterEncoding)", error.localizedDescription)
                }
            }
        case .urlFormEncoded:
            if let parameters {
                let urlComponents = Singleton.sharedInstance.apiServices.getQueryItems(forURLString: urlString,
                                                                                       withParameters: parameters)
                let formEncodedString = urlComponents?.percentEncodedQuery
                if let formEncodedData = formEncodedString?.data(using: .utf8) {
                    self.httpBody = formEncodedData
                    self.addValue("application/x-www-form-urlencoded",
                                  forHTTPHeaderField: "Content-Type")
                } else {
                    print("error in \(urlString) with parameterEncoding \(parameterEncoding)")
                }
            }
        case .formData:
            //https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift
            //https://orjpap.github.io/swift/http/ios/urlsession/2021/04/26/Multipart-Form-Requests.html
            //https://bhuvaneswarikittappa.medium.com/upload-image-to-server-using-multipart-form-data-in-ios-swift-5c4eb6de26e2
            
            let boundary = "Boundary-\(UUID().uuidString)"
            let lineBreak = "\r\n"
            
            var body = Data()
            
            if let parameters {
                parameters.forEach { key, value in
                    if let params = value as? JSONKeyPair, let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
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
            
            if let fileModel {
                for fileModel in fileModel {
                    body.appendString("--\(boundary + lineBreak)")
                    body.appendString("Content-Disposition: form-data; name=\"\(fileModel.fileKeyName)\"; filename=\"\(fileModel.fileName)\"\(lineBreak)")
                    body.appendString("Content-Type: \(fileModel.mimeType + lineBreak + lineBreak)")
                    body.append(fileModel.file)
                    body.appendString(lineBreak)
                }
            }
            
            body.appendString("--\(boundary)--\(lineBreak)")
            
            self.httpBody = body
            self.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            self.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            
            print("paramenterEncoding is", parameterEncoding)
            print("http paramters", parameters ?? [:])
            print("http body data", self.httpBody ?? Data())
        }
    }
}
