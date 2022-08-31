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
    
    func paginateWithIndex(_ index: Int, andExceutionBlock: @escaping (_ apiStatus: ApiStatus) -> Void) {
        if getCharactersAS != .IsBeingHit && index == currentLength - 1 && !fetchedAllData {
            getCharacters(withExcecutionBlock: andExceutionBlock, shouldClearList: false)
        }
    }
    
    func getCharacters(withExcecutionBlock: @escaping (_ apiStatus: ApiStatus) -> Void, shouldClearList clearList: Bool = true) {
        getCharactersAS = .IsBeingHit
        
        if clearList {
            currentLength = 0
            characters.removeAll()
        }
        
        let params = ["limit": 10, "offset": currentLength] as [String: Any]
        
        Singleton.sharedInstance.apiServices.hitApi(httpMethod: .GET, urlString: AppConstants.ApiEndPoints.characters, isAuthApi: false, parameterEncoding: .QueryParameters, params: params, decodingStruct: Characters.self) { [weak self] charactersResponse, jsonData in
            
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
            
            withExcecutionBlock(self?.getCharactersAS ?? .NotHitOnce)
        } outputBlockForInternetNotConnected: { [weak self] in
            self?.getCharacters(withExcecutionBlock: withExcecutionBlock, shouldClearList: clearList)
        }
    }
}
