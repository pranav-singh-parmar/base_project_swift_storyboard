//
//  ViewController.swift
//  base_project
//
//  Created by Pranav Singh on 18/08/22.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    //MARK: - outlets
    @IBOutlet private weak var charactersTV: UITableView!
    
    @IBOutlet private weak var noDataAvailableLabel: UILabel!
    
    @IBOutlet private weak var acitivityIndicatory: UIActivityIndicatorView!
    
    //MARK: - variablea
    private let charactersAC = CharactersApiClass()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Breaking Bad Characters"
        charactersTV.dataSource = self
        charactersTV.delegate = self
        charactersTV.refreshControl = refreshControl
        charactersAC.getCharacterswithExecutionBlock(updateScreenOnUpdaingApiStatus)
    }
    
    //MARK: - objc methods
    @objc func onRefresh(_ refreshControl: UIRefreshControl) {
        charactersAC.getCharacterswithExecutionBlock(updateScreenOnUpdaingApiStatus, shouldClearList: true)
    }
}

//MARK: - UITableView Delegate and DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charactersAC.characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = charactersTV.dequeueReusableCell(withIdentifier: String(describing: CharacterTableViewCell.self), for: indexPath) as! CharacterTableViewCell
        let characterModel = charactersAC.characters[indexPath.row]
        
        cell.characterIVWidthConstraint.constant = AppConstants.DeviceDimensions.width * 0.15
        cell.characterIV?.showImageFromURLString(characterModel.img ?? "")
        cell.characterNameLabel.text = characterModel.name ?? ""
        cell.characterPortrayedByLabel.text = characterModel.portrayed ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if charactersAC.isLastIndex(indexPath.row) {
            if charactersAC.fetchedAllData {
                tableView.tableFooterView = UIView()
            } else {
                tableView.tableFooterView = getSpinnerForTableView(tableView)
                charactersAC.paginateWithIndex(indexPath.row, andExecutionBlock: updateScreenOnUpdaingApiStatus)
            }
        }
    }
}

//MARK: - api's
extension ViewController {
    
    private func updateScreenOnUpdaingApiStatus() {
        switch charactersAC.getCharactersAS {
        case .IsBeingHit:
            if charactersAC.characters.isEmpty {
                acitivityIndicatory.isHidden = false
                acitivityIndicatory.startAnimating()
                charactersTV.isHidden = true
            } else {
                acitivityIndicatory.isHidden = true
                if acitivityIndicatory.isAnimating {
                    acitivityIndicatory.stopAnimating()
                }
                charactersTV.isHidden = false
            }
        case .ApiHit, .ApiHitWithError:
            acitivityIndicatory.isHidden = true
            if acitivityIndicatory.isAnimating {
                acitivityIndicatory.stopAnimating()
            }
            if charactersAC.characters.isEmpty {
                charactersTV.isHidden = true
                noDataAvailableLabel.isHidden = false
            } else {
                charactersTV.isHidden = false
                noDataAvailableLabel.isHidden = true
            }
            charactersTV.reloadData()
        default:
            break
        }
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}
