//
//  CharacterApiClass.swift
//  base_project
//
//  Created by Pranav Singh on 30/08/22.
//

import Foundation

class CharactersApiClass {
    
    private(set) var characters: [Character] = []
    
    private var total = 0
    private var currentLength = 0
    private(set) var getCharactersAS: ApiStatus = .NotHitOnce

    var fetchedAllData: Bool {
        return total <= currentLength
    }
    
    func isLastIndex(_ index: Int) -> Bool {
        return index == currentLength - 1
    }
    
    func paginateWithIndex(_ index: Int, andExecutionBlock excecutionBlock: @escaping () -> Void) {
        if getCharactersAS != .IsBeingHit && isLastIndex(index) && !fetchedAllData {
            getCharacterswithExecutionBlock(excecutionBlock, shouldClearList: false)
        }
    }
    
    func getCharacterswithExecutionBlock(_ excecutionBlock: @escaping () -> Void, shouldClearList clearList: Bool = true) {
        getCharactersAS = .IsBeingHit
        excecutionBlock()
        if clearList {
            currentLength = 0
            characters.removeAll()
        }
        
        let params = ["limit": 10, "offset": currentLength] as [String: Any]
        
        var urlRequest =
        Singleton.sharedInstance.apiServices.getURL(ofHTTPMethod: .get,
                                                    forAppEndpoint: .characters,
                                                    withQueryParameters: params)
        
        urlRequest?.addHeaders()
        Singleton.sharedInstance.apiServices.hitApi(withURLRequest: urlRequest,
                                                    decodingStruct: Characters.self) { [weak self] charactersResponse, jsonData in
            
            if let charactersResponse = charactersResponse {
                
                if clearList {
                    self?.characters.removeAll()
                }
                self?.characters.append(contentsOf: charactersResponse)
                self?.currentLength = self?.characters.count ?? 0
                self?.total = 30
                self?.getCharactersAS = .ApiHit
                
            } else {
                self?.getCharactersAS = .ApiHitWithError
            }
            
            excecutionBlock()
        } outputBlockForInternetNotConnected: { [weak self] in
            self?.getCharacterswithExecutionBlock(excecutionBlock, shouldClearList: clearList)
        }
    }
}
