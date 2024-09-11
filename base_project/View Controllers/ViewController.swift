//
//  ViewController.swift
//  base_project
//
//  Created by Pranav Singh on 18/08/22.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet private weak var charactersTV: UITableView!
    
    @IBOutlet private weak var emptyListView: EmptyListView!
    
    @IBOutlet private weak var acitivityIndicatory: UIActivityIndicatorView!
    
    //MARK: - Variables
    private let charactersAC = CharactersApiClass()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = AppTexts.breakingBadCharacters
        self.navigationController?.navigationBar.prefersLargeTitles = true
        acitivityIndicatory.hidesWhenStopped = true
        emptyListView.isHidden = true
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
        
        if indexPath.row == 0 {
            cell.topConstraint.constant = 16
        } else {
            cell.topConstraint.constant = 0
        }
        
        let characterModel = charactersAC.characters[indexPath.row]
        
        let width = UIScreen.main.width(withMultiplier: 0.15)
        cell.characterIVWidthConstraint.constant = width
        cell.characterIV.cornerRadius = width / 2
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

//MARK: - APIs
extension ViewController {
    
    private func updateScreenOnUpdaingApiStatus() {
        switch charactersAC.getCharactersAS {
        case .IsBeingHit:
            if charactersAC.characters.isEmpty {
                if !refreshControl.isRefreshing {
                    acitivityIndicatory.isHidden = false
                    acitivityIndicatory.startAnimating()
                }
                charactersTV.isHidden = true
            } else {
                acitivityIndicatory.isHidden = true
                if acitivityIndicatory.isAnimating {
                    acitivityIndicatory.stopAnimating()
                }
                charactersTV.isHidden = false
            }
        case .ApiHit, .ApiHitWithError:
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            } else {
                if acitivityIndicatory.isAnimating {
                    acitivityIndicatory.stopAnimating()
                }
            }
            if charactersAC.characters.isEmpty {
                charactersTV.isHidden = true
                emptyListView.isHidden = false
            } else {
                charactersTV.isHidden = false
                emptyListView.isHidden = true
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
