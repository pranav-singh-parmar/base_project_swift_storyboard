//
//  ApiServices.swift
//  base_project
//
//  Created by Pranav Singh on 24/08/22.
//

import Foundation
import Network

extension URLRequest {
    
    private static let apiErrorTAG = "APIError:"
    
    var getURLString: String {
        return self.url?.absoluteString ?? "URL not set"
    }
    
    //MARK: - Initializers
    init?(ofHTTPMethod httpMethod: HTTPMethod,
          forAppEndpoint appEndpoint: AppEndpoints,
          withQueryParameters queryParameters: JSONKeyPair?) {
        self.init(withHTTPMethod: httpMethod,
                  forAppEndpoint: appEndpoint,
                  withQueryParameters: queryParameters)
    }
    
    init?(ofHTTPMethod httpMethod: HTTPMethod,
         forAppEndpoint appEndpoint: AppEndpointsWithParamters,
         withQueryParameters queryParameters: JSONKeyPair?) {
        self.init(withHTTPMethod: httpMethod,
                  forAppEndpoint: appEndpoint,
                  withQueryParameters: queryParameters)
    }
    
    private init?(withHTTPMethod httpMethod: HTTPMethod,
                  forAppEndpoint appEndpoint: EndpointsProtocol,
                  withQueryParameters queryParameters: JSONKeyPair?) {
        let urlString = appEndpoint.getURLString()
        guard let url = URL(string: urlString) else {
            print(URLRequest.apiErrorTAG, "Cannot Initiate URL with String", urlString)
            return nil
        }
        
        self.init(url: url)
        printRequestDetailsWhenStarted(true)
        if let queryParameters {
            let urlComponents = getQueryItems(withParamters: queryParameters)
            if let url = urlComponents?.url {
                self.url = url
            }
            print("Query Paramters:", queryParameters)
            print("URL with Query Parameter:", self.getURLString)
        }
        self.httpMethod = httpMethod.rawValue
        print("HTTP Method:", self.httpMethod ?? "http method not assigned")
    }
    
    //MARK: - Query Parameters
    private func getQueryItems(withParamters parameters: JSONKeyPair) -> URLComponents? {
        var urlComponents = URLComponents(string: self.getURLString)
        urlComponents?.queryItems = []
        for (keyName, value) in parameters {
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
    
    //MARK: - Headers
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
    
    //MARK: - Parameters
    mutating func addParameters(_ parameters: JSONKeyPair?, withFileModel fileModel: [FileModel]? = nil, as parameterEncoding: ParameterEncoding) {
        let urlString = self.getURLString
        switch parameterEncoding {
        case .jsonBody:
            if let parameters {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                    self.httpBody = jsonData
                    self.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    print("error in \(urlString) with parameterEncoding \(parameterEncoding)", error.localizedDescription)
                }
            }
        case .urlFormEncoded:
            if let parameters {
                let urlComponents = self.getQueryItems(withParamters: parameters)
                let formEncodedString = urlComponents?.percentEncodedQuery
                if let formEncodedData = formEncodedString?.data(using: .utf8) {
                    self.httpBody = formEncodedData
                    self.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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
                    if let params = value as? JSONKeyPair,
                       let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
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
            
            print("ParamenterEncoding:", parameterEncoding)
            print("Parameters:", parameters ?? [:])
            print("Body Data:", self.httpBody ?? Data())
        }
    }
    
    func hitApi<T: Decodable>(decodingStruct: T.Type,
                              returnRequired: JsonStructEnum = JsonStructEnum.OnlyModel,
                              outputBlockForSucess: @escaping (_ receivedData: T?,_ jsonData: AnyObject?) -> Void,
                              outputBlockForInternetNotConnected: @escaping () -> Void) {
        
        print("Headers:", self.allHTTPHeaderFields ?? [:])
        
        if Singleton.sharedInstance.internetConnectivity.isConnectedToInternet {
            
            URLSession.shared.dataTask(with: self) { (data, response, error) in
                printResponseDetailsWhenStarted(true)
                
                guard error == nil else {
                    self.printApiError(.mapError)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else{
                    self.printApiError(.invalidHTTPURLResponse)
                    return
                }
                
                guard let data = data else{
                    self.printApiError(.dataNotReceived)
                    return
                }
                
                DispatchQueue.main.async {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                    let json = jsonObject as AnyObject
                    
                    switch response.statusCode {
                    case 100...199:
                        self.printApiError(.informationalError(response.statusCode))
                    case 200...299:
                        switch returnRequired {
                        case .OnlyModel, .Both:
                            do {
                                // let jsonData = try JSONSerialization.data(withJSONObject: json as AnyObject, options: .prettyPrinted)
                                // let data = try JSONDecoder().decode(decodingStruct.self, from: jsonData)
                                let model = try JSONDecoder().decode(decodingStruct.self, from: data)
                                
                                printResponseDetailsWhenStarted(false)
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
                                self.printApiError(.decodingError)
                            } catch let DecodingError.keyNotFound(key, context) {
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                                self.printApiError(.decodingError)
                            } catch let DecodingError.valueNotFound(value, context) {
                                print("Value '\(value)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                                self.printApiError(.decodingError)
                            } catch let DecodingError.dataCorrupted(context) {
                                print("Data Corrupted:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                                self.printApiError(.decodingError)
                            } catch {
                                self.printApiError(.decodingError)
                            }
                        case .OnlyJson:
                            printResponseDetailsWhenStarted(false)
                            outputBlockForSucess(nil, json as AnyObject)
                            //added return here if not added here then outblock with nil, nil will be excecuted
                            return
                        }
                    case 300...399:
                        self.printApiError(.redirectionalError(response.statusCode))
                    case 400...499:
                        let clientErrorEnum = ClientErrorsEnum(rawValue: response.statusCode) ?? .other
                        switch clientErrorEnum {
                        case .unauthorized:
                            Singleton.sharedInstance.alerts.handle401StatueCode()
                        case .badRequest, .paymentRequired, .forbidden, .notFound, .methodNotAllowed, .notAcceptable, .uriTooLong, .other:
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
                        self.printApiError(.clientError(clientErrorEnum))
                    case 500...599:
                        self.printApiError(.serverError(response.statusCode))
                    default:
                        self.printApiError(.unknown(response.statusCode))
                        break
                    }
                    //added so that the screen updates even receiving an error
                    outputBlockForSucess(nil, nil)
                }
            }.resume()
        } else {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: self.getURLString)
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    if path.status == .satisfied {
                        outputBlockForInternetNotConnected()
                        monitor.cancel()
                    }
                }
            }
            monitor.start(queue: queue)
            self.printApiError(.internetNotConnected)
        }
        
        printRequestDetailsWhenStarted(false)
    }
    
    private func printApiError(_ apiError: APIError) {
        print(URLRequest.apiErrorTAG, "\(apiError)")
        if apiError.localizedDescription != APIError.internetNotConnected.localizedDescription {
            printResponseDetailsWhenStarted(false)
        }
    }
    
    private func printRequestDetailsWhenStarted(_ started: Bool) {
        if started {
            print("\n-----URL Request Details Starts-----")
            print("URL:", self.getURLString)
        } else {
            print("-----URL Request Details Ends-----\n")
        }
    }
    
    private func printResponseDetailsWhenStarted(_ started: Bool) {
        if started {
            print("\n-----URL Response Details Starts-----")
            print("URL:", self.getURLString)
        } else {
            print("-----URL Response Details Ends-----\n")
        }
    }
}
