//
//  TransferAmountController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferAmountController: PlanetWalletViewController {
    
    var planet: Planet = Planet()
    var mainItem: MainItem = MainItem()
    var tx:Tx = Tx()
    
    var inputAmount:String = "0"
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var keyPad: NumberPad!
    @IBOutlet var availableAmountLb: UILabel!
    @IBOutlet var inputAmountLb: UILabel!
    @IBOutlet var currencyLb: UILabel!
    @IBOutlet var submitBtn: PWButton!
    
    @IBOutlet var titleWithPlanetContainer: UIView!
    @IBOutlet var titlePlanetView: PlanetView!
    @IBOutlet var titlePlanetNameLb: PWLabel! {
        didSet {
            titlePlanetNameLb.font = Utils.shared.planetFont(style: .SEMIBOLD, size: 18)
        }
    }
    
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        keyPad.delegate = self
        naviBar.delegate = self
        
        keyPad.shouldPoint = true
        
        if SCREEN_HEIGHT < 600 {
            inputAmountLb.adjustsFontSizeToFitWidth = true
            inputAmountLb.minimumScaleFactor = 0.65
        }
    }
    
    override func setData() {
        super.setData()
        
        guard
            let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem,
            let tx = userInfo[Keys.UserInfo.tx] as? Tx else { self.navigationController?.popViewController(animated: false); return }
        
        
        self.planet = planet
        self.mainItem = mainItem
        self.tx = tx
        
        
        // bind balance
        if let symbol = mainItem.symbol{
            availableAmountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)) \(symbol)"
        }
        
        //Planet or Address
        if let toPlanetName = tx.to_planet {
            titlePlanetNameLb.text = toPlanetName
            titlePlanetView.isHidden = false
            guard let address = tx.to else { return }
            titlePlanetView.data = address
        }
        else if let address = tx.to {
            titlePlanetNameLb.text = Utils.shared.trimAddress(address)
            titlePlanetView.isHidden = true
        }
        
        Get(self).action(Route.URL("balance", mainItem.symbol!, planet.address!),
                         requestCode: 0,
                         resultCode: 0,
                         data: nil,
                         extraHeaders: ["device-key": DEVICE_KEY])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAmount()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSubmit(_ sender: UIButton) {
        tx.amount = CoinNumberFormatter.full.toMinUnit(balance: inputAmount, item: mainItem)
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM,
                   userInfo: [Keys.UserInfo.planet: planet,
                              Keys.UserInfo.mainItem: mainItem,
                              Keys.UserInfo.tx: tx])
    }
    
    
    
    //MARK: - Network
    private func handleBalanceResponse(json: [String: Any]) {
        if let balance = MainItem(JSON: json){
            
            self.mainItem.balance = balance.getBalance()
            // bind balance
            if let symbol = mainItem.symbol{
                availableAmountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)) \(symbol)"
            }
            
        }
        
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard success, let dict = dictionary, let resultObj = dict["result"] as? [String:Any] else { return }
        self.handleBalanceResponse(json: resultObj)
    }
    
    func checkAmount(){
        
        if let amount = Decimal(string: inputAmount){
            if( amount == 0 ){
                
                submitBtn.setEnabled(false, theme: currentTheme)
                
            }else{

                if let balance = Decimal(string:CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)){
                    if mainItem.getCoinType() == CoinType.ERC20.coinType {
                        //both check (Eth fee & balance)
                        guard let ethAmountStr = planet.getMainItem()?.getBalance(),
                            let ethAmount = Decimal(string: ethAmountStr) else
                        {
                            setDisableAmountUI("transfer_amount_not_balance_title".localized)
                            return
                        }
                        
                        if balance >= amount {
                            if ethAmount <= 0 {
                                setDisableAmountUI("transfer_amount_not_fee_title".localized)
                                return
                            }
                            else {
                                submitBtn.setEnabled(true, theme: currentTheme)
                            }
                        }
                        else {
                            setDisableAmountUI("transfer_amount_not_balance_title".localized)
                            return
                        }
                    }
                    else {
                        if balance <= amount{
                            setDisableAmountUI("transfer_amount_not_balance_title".localized)
                            return
                        }else{
                            submitBtn.setEnabled(true, theme: currentTheme)
                        }
                    }
                }else{
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
                
            }
        }else{
            inputAmount = "0"
        }
        
        currencyLb.text = "-"
        currencyLb.textColor = UIColor.clear
        inputAmountLb.text = inputAmount
    }
    
    private func setDisableAmountUI(_ msg: String) {
        currencyLb.text = msg
        currencyLb.textColor = UIColor(red: 255, green: 0, blue: 80)
        inputAmountLb.text = inputAmount
        submitBtn.setEnabled(false, theme: currentTheme)
    }
    
}


extension TransferAmountController: NumberPadDelegate {
   
    func didTouchedDelete() {
        self.inputAmount = String(inputAmount.dropLast())
        checkAmount()
    }
    
    func didTouchedNumberPad(_ num: String) {
        
        if let _ = Int(num) {
            
            if inputAmount == "0" { inputAmount = "" }
            
            inputAmount += num
            if( inputAmount.contains(".") ){
                
                if let inputAmountDecimal = Decimal(string: inputAmount){
                    if let precision = CoinType.of(mainItem.getCoinType()).precision{
                        if inputAmountDecimal.significantFractionalDecimalDigits > precision{
                            self.inputAmount = String(inputAmount.dropLast())
                            return
                        }
                    }else if let decimals = mainItem.decimals, let precision = Int(decimals){
                        if inputAmountDecimal.significantFractionalDecimalDigits > precision{
                            self.inputAmount = String(inputAmount.dropLast())
                            return
                        }
                    }
                }
            }
        }else {
            if( !inputAmount.contains(".") ){
                inputAmount += num
            }
        }
        checkAmount()
    }
    
}

extension TransferAmountController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
