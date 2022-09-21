//
//  EmptyListView.swift
//  base_project
//
//  Created by Pranav Singh on 21/09/22.
//

import Foundation
import UIKit

class EmptyListView: UIView {
    
    //MARK: - Outlets
    @IBOutlet weak var outerSV: UIStackView!
    
    @IBOutlet weak var emptyListIV: UIImageView!
    
    @IBOutlet weak var emptyListIVHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    //MARK: - variables
    private let nibName = String(describing: EmptyListView.self)
    
    //MARK: - Lifecycle methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    //MARK: - custom methods
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        emptyListIVHeight.constant = DeviceDimensions.width * 0.7
        emptyLabel.text = AppTexts.noDataFound
        emptyListIV.image = UIImage(named: "noDataFoundImage")
    }
     
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func resetViewWithTitle(_ title: String, andImageName image: String) {
        self.emptyLabel.text = title
        self.emptyListIV.image = UIImage(named: image)
    }
}
