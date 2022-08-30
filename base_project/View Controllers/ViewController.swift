//
//  ViewController.swift
//  base_project
//
//  Created by Pranav Singh on 18/08/22.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - outlets
    @IBOutlet weak var charactersTV: UITableView!
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        charactersTV.dataSource = self
        charactersTV.delegate = self
    }
}

//MARK: - UITableView Delegate and DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = charactersTV.dequeueReusableCell(withIdentifier: String(describing: CharacterTableViewCell.self), for: indexPath) as! CharacterTableViewCell
        // let characterModel =
        cell.characterIVWidthConstraint.constant = AppConstants.DeviceDimensions.width * 0.15
//        cell.characterNameLabel.text =
//        cell.characterPortrayedByLabel.text =
        return cell
    }
}

