//
//  BTCHistoryCell.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BTCTransactionCell: PWTableCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    @IBOutlet var amountLb: UILabel!
    
    @IBOutlet var directionImgView: UIImageView!
    
    public var viewModel: BTCTransactionViewModel? {
        didSet {
            self.amountLb.text = viewModel?.amount
            self.dateLb.text = viewModel?.date
            self.planetNameLb.text = viewModel?.name
            self.directionImgView.image = viewModel?.directionImg
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("BTCTransactionCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }


}
