//
//  PrivateKeyImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PrivateKeyImportController: PlanetWalletViewController {

    @IBOutlet var pwTextFieldContainer: PWView!
    @IBOutlet var textField: PWTextField!
    
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var continueBtn: PWButton!
    
    private var isValidPrivateKey = false {
        didSet {
            updateValidUI()
        }
    }
    
    var planet:Planet = Planet()
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        textField.delegate = self
        continueBtn.setEnabled(true, theme: currentTheme)
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo, let universeType = userInfo[Keys.UserInfo.universe] as? String {
            if universeType == CoinType.BTC.name {
                planet.coinType = CoinType.BTC.coinType
            }
            else if universeType == CoinType.ETH.name {
                planet.coinType = CoinType.ETH.coinType
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedInvisible(_ sender: PWButton) {
        
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        
        if let coinType = planet.coinType, let privateKey = textField.text {
            
            if coinType == CoinType.BTC.coinType{
                let importedPlanet = BitCoinManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
                
                if let keyId = importedPlanet.keyId{
                    if PlanetStore.shared.get(keyId) != nil{
                        Toast.init(text: "privatekey_import_exists_title".localized).show()
                    }else{
                        let info = [Keys.UserInfo.planet:importedPlanet]
                        sendAction(segue: Keys.Segue.PRIVATEKEY_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }
                else {
                    Toast.init(text: "privatekey_import_not_match_title".localized).show()
                }
            }else if coinType == CoinType.ETH.coinType{
                let importedPlanet = EthereumManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
                
                if let keyId = importedPlanet.keyId{
                    if PlanetStore.shared.get(keyId) != nil{
                        Toast.init(text: "privatekey_import_exists_title".localized).show()
                    }else{
                        let info = [Keys.UserInfo.planet:importedPlanet]
                        sendAction(segue: Keys.Segue.PRIVATEKEY_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }
                else {
                    Toast.init(text: "privatekey_import_not_match_title".localized).show()
                }
            }
        }
    }
    
    
    //MARK: - Private
    private func isValid(_ privateKey: String) -> Bool {
        //TODO: - Logic
        return false
    }
    
    private func updateValidUI() {
        if isValidPrivateKey {
            continueBtn.setEnabled(true, theme: currentTheme)
            errMsgContainerView.isHidden = true
        }
        else {
            continueBtn.setEnabled(false, theme: currentTheme)
            errMsgContainerView.isHidden = false
        }
    }
}

//MARK: - UITextFieldDelegate
extension PrivateKeyImportController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        isValidPrivateKey = false
        textField.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.border.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else { return false }
        //Regex 0...9 && a...f && A...F
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Fa-f0-9].*", options: [])
            if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                isValidPrivateKey = false
                return false
            }
        }
        catch {
            print("ERROR")
        }
        
        let length = textFieldText.utf16.count + string.utf16.count - range.length
        
        if length >= 1 {
            isValidPrivateKey = true
        }
        else {
            isValidPrivateKey = false
        }
        
        return true
    }
}
