//
//  ViewController.swift
//  base_project
//
//  Created by Pranav Singh on 18/08/22.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - outlets
    @IBOutlet private weak var charactersTV: UITableView!
    
    @IBOutlet private weak var acitivityIndicatory: UIActivityIndicatorView!
    
    //MARK: - variablea
    private let charactersAC = CharactersApiClass()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        charactersTV.dataSource = self
        charactersTV.delegate = self
        charactersAC.getCharacters(withExcecutionBlock: updateScreenOnReceivingApiStatus)
    }
    
    //MARK: - obj methods
    @objc func onRefresh(_ refreshControl: UIRefreshControl) {
        charactersAC.getCharacters(withExcecutionBlock: updateScreenOnReceivingApiStatus, shouldClearList: true)
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
        cell.characterNameLabel.text = characterModel.name ?? ""
        cell.characterPortrayedByLabel.text = characterModel.portrayed ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        charactersAC.paginateWithIndex(indexPath.row, andExceutionBlock: updateScreenOnReceivingApiStatus)
    }
}

//MARK: - api's
extension ViewController {
    
    private func updateScreenOnReceivingApiStatus(_ apiStatus: ApiStatus) {
        switch apiStatus {
        case .IsBeingHit:
            if charactersAC.characters.isEmpty {
                acitivityIndicatory.isHidden = false
                charactersTV.isHidden = true
            } else {
                acitivityIndicatory.isHidden = false
                charactersTV.isHidden = false
            }
        case .ApiHit, .ApiHitWithError:
            acitivityIndicatory.isHidden = true
            if charactersAC.fetchedAllData {
                charactersTV.tableFooterView = UIView()
            } else {
                let spinner = UIActivityIndicatorView(style: .gray)
                spinner.startAnimating()
                spinner.hidesWhenStopped = true
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: charactersTV.bounds.width, height: CGFloat(44))
                charactersTV.tableFooterView = spinner
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
