//
//  BTCHistoryDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

struct BTCTransaction {
    
}

class BTCTransactionDataSource: NSObject, UITableViewDataSource {
    let cellID = "btcTransactionHistoryCell"
    
    var transactionList: [BTCTransaction]? = []
    
    override init() {
        super.init()
        
        self.transactionList = [BTCTransaction()]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = transactionList {
            return list.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BTCTransactionCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
}