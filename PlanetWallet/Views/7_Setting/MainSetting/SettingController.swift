//
//  SettingController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class SettingController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var darkThemeBtn: UIButton!
    @IBOutlet var lightThemeBtn: UIButton!
    @IBOutlet var helloLb: PWLabel!
    @IBOutlet var currencyLb: PWLabel!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var versionLb: PWLabel!
    @IBOutlet var updateBadge: UIImageView!
    
    var selectedPlanet: Planet? {
        didSet {
            updatePlanetUI()
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        updateThemeUI()
        
        //Fade transition animation
        self.view.subviews.forEach { (v) in
            v.alpha = 0;
            UIView.animate(withDuration: 0.2, animations: {
                v.alpha = 1.0
            })
        }
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let address = planet.address,
            let name = planet.name
        {
            self.selectedPlanet = planet
            self.planetView.data = address
            self.helloLb.text = String(format: "setting_planet_main_title".localized, name)
        }
        
        if let currency = UserDefaults.standard.string(forKey: Keys.Userdefaults.CURRENCY) {
            currencyLb.text = currency
        }
        
        versionLb.text = Utils.shared.getVersion()
        updateBadge.isHidden = !compareVersion(recentVersion: RECENT_VERSION)
        
        Get(self).action(Route.URL("version","ios"), requestCode: 0, resultCode: 0, data: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        updatePlanetUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let mainNaviCon = self.navigationController as? MainNavigationController {
            navigationController?.interactivePopGestureRecognizer?.delegate = mainNaviCon
        }
        else {
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedTheme(_ sender: UIButton) {
        
        if sender.tag == 0 {
            //DARK Theme
            currentTheme = .DARK
        }
        else {
            //Light Theme
            currentTheme = .LIGHT
        }
        
        updateThemeUI()
    }
    
    @IBAction func didTouchedAnnouncements(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.SETTING_TO_BOARD, userInfo: ["section": BoardController.Category.ANNOUNCEMENTS])
    }
    
    @IBAction func didTouchedCurrency(_ sender: UIButton) {
        let popup = PopupCurrency()
        popup.show(controller: self)
        popup.handler = { [weak self](currency) in
            guard let strongSelf = self else { return }
            var currencyStr = ""
            switch currency {
            case .KRW:      currencyStr = "KRW"
            case .USD:      currencyStr = "USD"
            case .CNY:      currencyStr = "CNY"
            }
            
            UserDefaults.standard.set(currencyStr, forKey: Keys.Userdefaults.CURRENCY)
            strongSelf.currencyLb.text = currencyStr
            popup.dismiss()
        }
    }
    
    @IBAction func didTouchedVersion(_ sender: UIButton) {
        if !updateBadge.isHidden {
            
            if let url = URL(string: APP_URL){
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        }
    }
    
    
    @IBAction func didTouchedMyPlanet(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.SETTING_TO_DETAIL_PLANET, userInfo: userInfo)
    }
    
    @IBAction func didTouchedManagePlanets(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.SETTING_TO_PLANET_MANAGEMENT, userInfo: userInfo)
    }
    
    //MARK: - Private
    private func updateThemeUI() {
        switch currentTheme {
        case .DARK:
            darkThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
            lightThemeBtn.layer.borderColor = settingTheme.border.cgColor
        case .LIGHT:
            darkThemeBtn.layer.borderColor = settingTheme.border.cgColor
            lightThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
        }
    }
    
    private func updatePlanetUI() {
        if let planet = self.selectedPlanet,
            let address = planet.address,
            let name = planet.name
        {
            self.planetView.data = address
            self.helloLb.text = String(format: "setting_planet_main_title".localized, name)
        }
    }
    
    private func compareVersion(recentVersion: String) -> Bool {
        if let recentVer = Decimal(string: recentVersion), let localVersion = Utils.shared.getVersion(), let localVer = Decimal(string: localVersion) {
            return  recentVer > localVer
        }
        return false
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard success,
            let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if isSuccess {
            if let results = returnVo.result as? [String: Any] {
                
                if let versionStr = results["version"] as? String  {
                    updateBadge.isHidden = !compareVersion(recentVersion: versionStr)
                    RECENT_VERSION = versionStr
                }
                
                if let url = results["url"] as? String {
                    APP_URL = url
                }
            }
            
        }
        else {
            if let errDict = returnVo.result as? [String: Any]
            {
                Utils.shared.showNetworkErrorToast(json: errDict)
            }
        }
    }
}

extension SettingController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.view.subviews.forEach { (v) in
                UIView.animate(withDuration: 0.3, animations: {
                    v.alpha = 0
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}

extension SettingController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
