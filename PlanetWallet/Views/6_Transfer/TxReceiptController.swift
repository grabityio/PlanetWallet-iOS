//
//  TxReceiptController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TxReceiptController: PlanetWalletViewController {
    
    @IBOutlet var toAddressContainer: UIView!
    @IBOutlet var toAddressCoinImgView: PWImageView!
    @IBOutlet var toAddressLb: UILabel!
    
    @IBOutlet var toPlanetContainer: UIView!
    @IBOutlet var toPlanetView: PlanetView!
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    
    @IBOutlet var mainAmountLb: PWLabel!
    
    @IBOutlet var fromPlanetNameLb: PWLabel!
    @IBOutlet var amountLb: UILabel!
    @IBOutlet var gasFeeLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    @IBOutlet var txHashValueLb: UILabel!
    
    
    override func viewInit() {
        super.viewInit()
        
        guard let userInfo = userInfo,
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet,
            let toPlanet = userInfo[Keys.UserInfo.toPlanet] as? Planet,
            let txHash = userInfo[Keys.UserInfo.txHash] as? String,
            let amount = userInfo[Keys.UserInfo.transferAmount] as? Double,
            let gasFee = userInfo[Keys.UserInfo.gasFee] as? Double else { return }
        
        var transactionSymbol = ""
        var toName = ""
        
        if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let symbol = erc20.symbol {
            mainAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
            amountLb.text = "\(amount) \(erc20.symbol ?? "")"
            transactionSymbol = symbol
        }
        else {
            guard let coinType = fromPlanet.coinType else { return }
            if coinType == CoinType.BTC.coinType {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                transactionSymbol = "BTC"
            }
            else if coinType == CoinType.ETH.coinType {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
                transactionSymbol = "ETH"
            }
            
            mainAmountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
            amountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
        }
        
        
        
        if let toPlanetName = toPlanet.name {
            toPlanetContainer.isHidden = false
            toAddressContainer.isHidden = true
            
            toPlanetNameLb.text = toPlanetName
            toPlanetView.data = toPlanet.address ?? ""
            toPlanetAddressLb.text = Utils.shared.trimAddress(toPlanet.address ?? "")
            
            toName = toPlanetName
        }
        else {
            toPlanetContainer.isHidden = true
            toAddressContainer.isHidden = false
            
            toAddressLb.text = toPlanet.address
            toAddressLb.setColoredAddress()
        }
        
        fromPlanetNameLb.text = fromPlanet.name ?? ""
        gasFeeLb.text = "\(gasFee)"//gasFee
        dateLb.text = Utils.shared.getStringFromDate(Date(), format: .yyyyMMddHHmmss)
        txHashValueLb.attributedText = NSAttributedString(string: txHash,
                                                          attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                       NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        //Insert Search DB
        if let toAddress = toPlanet.address, let keyId = fromPlanet.keyId {
            let recent = Search(keyId: keyId, name: toName, address: toAddress, symbol: transactionSymbol)
            SearchStore.shared.insert(recent)
        }
        
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedOK(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedExport(_ sender: UIButton) {
        
    }
    
    //MARK: - Private
    private func dismiss() {
        sendAction(segue: Keys.Segue.MAIN_UNWIND, userInfo: nil)
    }
    
}
