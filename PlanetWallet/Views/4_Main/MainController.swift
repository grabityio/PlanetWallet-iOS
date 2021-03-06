//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class MainController: PlanetWalletViewController{
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelError: PWButton!
    
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var footerView: FooterView!
    @IBOutlet var bottomPanelComponent: BottomPanelComponent!
    
    var statusHeight: CGFloat { return Utils.shared.statusBarHeight() }
    
    var planet: Planet?
    
    var refreshComponent:RefreshAnimationComponent!
    var topMenuLauncher: TopMenuLauncher!
    var bottomMenuLauncher: BottomMenuLauncher!
    let rippleAnimationView = RippleAnimationView()
    
    private var mainAdapter: MainETHAdapter?
    private var txAdapter: TxAdapter?
    
    override func viewDidLayoutSubviews() {
        
        if topMenuLauncher == nil {
            self.topMenuLauncher = TopMenuLauncher(triggerView: naviBar.rightItemBtn)
            topMenuLauncher?.delegate = self
            topMenuLauncher?.planetList = PlanetStore.shared.list("", false)
        }
        
        if bottomMenuLauncher == nil {
            bottomMenuLauncher = BottomMenuLauncher(controller: self,
                                                    trigger: bottomPanelComponent,
                                                    clickTrigger: bottomPanelComponent.btnNext)
            bottomMenuLauncher?.labelError = labelError
            bottomMenuLauncher?.planet = planet
            bottomMenuLauncher?.bottomPanelComponent = bottomPanelComponent
        }
        
    }
    
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initBackupAlertView()
        rippleAnimationView.dismiss()
        
        self.getPlanet()
        self.updatePlanet()
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        configureTableView()
        createRippleView()
        
        naviBar.backgroundView.alpha = 0
    }
    
    override func setData() {
        super.setData()
        NodeService.shared.delegate = self
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        topMenuLauncher?.setTheme(theme)
        bottomMenuLauncher?.setTheme(theme)
        footerView.setTheme(theme)
        headerView.setTheme(theme)
    }

    //MARK: - IBAction
    @IBAction func didTouchedError(_ sender: UIButton) {
        if let planet = planet//, let type = planet.coinType
        {
            let segue = Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            sendAction(segue: segue, userInfo: [Keys.UserInfo.fromSegue: segue,
                                                Keys.UserInfo.planet: planet])
        }
        
    }
    
    @IBAction func unwindToMainController(segue:UIStoryboardSegue) { }
    
    //MARK: - Private
    private func getPlanet() {
        let planetList = PlanetStore.shared.list("", false)
        topMenuLauncher?.planetList = planetList
        
        // set selected planet
        if let keyId:String = Utils.shared.getDefaults(for: Keys.Userdefaults.SELECTED_PLANET){
            if let planet = PlanetStore.shared.get(keyId){
                self.planet = planet
            }else{
                self.planet = planetList.first
            }
        }else {
            self.planet = planetList.first
        }
        
        setDefaultGBT()
    }
    
    private func setDefaultGBT() {
        if let coinType = planet?.coinType,
            let keyId = planet?.keyId
        {
            let items = MainItemStore.shared.list(keyId)
            if CoinType.of(coinType).coinType == CoinType.ETH.coinType &&
                items.contains(where: { $0.contract == GBT_CONTRACT }) == false
            {
                let gbtToken = MainItem()
                gbtToken.contract = GBT_CONTRACT
                gbtToken.symbol = "GBT"
                gbtToken.name = "Grabity Coin"
                gbtToken.decimals = "18"
                gbtToken.img_path = "/img/erc20/gbt.png"
                gbtToken.hide = "N"
                gbtToken.keyId = keyId
                gbtToken.coinType = CoinType.ERC20.coinType
                MainItemStore.shared.tokenSave(gbtToken)
            }
        }
    }
    
    private func initBackupAlertView() {
        if let planet = planet, let type = planet.coinType, let pathIdx = planet.pathIndex
        {
            if pathIdx >= 0 {//Generate Planet
                labelError.isHidden = false
                
                if CoinType.BTC.coinType == type && UserDefaults.standard.bool(forKey: Keys.Userdefaults.BACKUP_MNEMONIC_BTC) {
                    labelError.isHidden = true
                }
                else if CoinType.ETH.coinType == type && UserDefaults.standard.bool(forKey: Keys.Userdefaults.BACKUP_MNEMONIC_ETH) {
                    labelError.isHidden = true
                }
            }
            else { //Import Planet
                labelError.isHidden = true
            }
        }
    }
    
    private func configureTableView() {
        
        tableView.contentInset = UIEdgeInsets(top: naviBar.frame.height - Utils.shared.statusBarHeight(),
                                              left: 0, bottom: 130, right: 0)
        
        refreshComponent = RefreshAnimationComponent()
        refreshComponent.controller(self)
        
        headerView.controller(self)
        headerView.refreshComponent = refreshComponent
        
        footerView.controller(self)

    }
    
    private func createRippleView() {
        self.rippleAnimationView.frame = CGRect(x: 31,
                                                y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0,
                                                width: 0,
                                                height: 0)
        self.view.addSubview(rippleAnimationView)
    }
    
    private func updatePlanet() {
        
        if let planet = planet, let coinType = planet.coinType {
            
            Utils.shared.setDefaults(for: Keys.Userdefaults.SELECTED_PLANET, value: planet.keyId ?? "" )
            
            //set mainItem
            if let keyId = planet.keyId{
                planet.items = MainItemStore.shared.list(keyId, false)
            }
            
            if CoinType.of(coinType).coinType == CoinType.BTC.coinType {
                naviBar.title = "BTC"
                
                txAdapter = TxAdapter(tableView, [Tx]())
                txAdapter?.delegates.append(self)
                txAdapter?.dataSetNotify(getTxFromLocal())
                
            }else if CoinType.of(coinType).coinType == CoinType.ETH.coinType {
                naviBar.title = "ETH"
                
                mainAdapter = MainETHAdapter(tableView, planet.items ?? [MainItem]() )
                mainAdapter?.delegates.append(self)
                
            }
            
            headerView.planet = planet
            footerView.planet = planet
            bottomMenuLauncher?.planet = planet
            bottomPanelComponent.setPlanet(planet)
            
            self.initBackupAlertView()

            NodeService.shared.getBalance(planet)
            NodeService.shared.getMainList(planet)
        }
    }
    
    private func getTxFromLocal() -> [Tx] {
        var transactionList = [Tx]()
        
        guard let planet = planet, let keyId = planet.keyId else { return transactionList }
        
        if let jsonArr = UserDefaults.standard.array(forKey: "BTC_BTC_\(keyId)") as? Array<[String: Any]> {
            jsonArr.forEach { (json) in
                if let tx = Tx(JSON: json) {
                    transactionList.append(tx)
                }
            }
        }
        
        return transactionList
    }
    
    private func saveTx(_ list: [Tx]) {
        
        guard let planet = planet, let keyId = planet.keyId else { return }
        
        var dictArr = Array<[String : Any]>()
        list.forEach { (tx) in
            dictArr.append(tx.toJSON())
        }
        
        UserDefaults.standard.set(dictArr, forKey: "BTC_BTC_\(keyId)")
    }

}

extension MainController: RefreshDelegate{
    func onRefresh() {
        SyncManager.shared.syncPlanet(self)
        if let planet = planet{
            NodeService.shared.getBalance(planet)
            NodeService.shared.getMainList(planet)
        }
    }
}


//MARK: - SyncDelegate
extension MainController: SyncDelegate {
    func sync(_ syncType: SyncType, didSyncComplete complete: Bool, isUpdate: Bool) {
        
    }
}

//MARK: - NavigationBarDelegate
extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            rippleAnimationView.show { (isSuccess) in
                if isSuccess {
                    guard let planet = self.planet else { return }
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: [Keys.UserInfo.planet: planet])
                }
            }
        }
    }
}


//MARK: - UITableViewDelegate
extension MainController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedPlanet = planet, let coinType = selectedPlanet.coinType {
            
            if coinType == CoinType.BTC.coinType {
                
                if let tx = txAdapter?.dataSource[indexPath.row], let item = selectedPlanet.getMainItem() {
                    sendAction(segue: Keys.Segue.MAIN_TO_DETAIL_TX, userInfo: [Keys.UserInfo.planet : selectedPlanet,
                                                                               Keys.UserInfo.mainItem : item,
                                                                               Keys.UserInfo.tx : tx])
                }
                
            }
            else if coinType == CoinType.ETH.coinType || coinType == CoinType.ERC20.coinType {

                if let item = mainAdapter?.dataSource[indexPath.row] {
                    sendAction(segue: Keys.Segue.MAIN_TO_TX_LIST,
                               userInfo: [Keys.UserInfo.planet : selectedPlanet,
                                          Keys.UserInfo.mainItem: item as Any])
                }
              
            }
        }
        
    }
}

//MARK: - UIScrollViewDelegate
extension MainController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.scrollViewDidScroll(scrollView)
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidScroll(scrollView)
        }
    }
}

//MARK: - TopMenuLauncherDelegate
extension MainController: TopMenuLauncherDelegate {
    func didSelected(planet: Planet) {
        self.planet = planet
        setDefaultGBT()
        updatePlanet()
    }
    
    func didSelectedFooter() {
        topMenuLauncher?.handleDismiss {
            let segueID = Keys.Segue.MAIN_TO_WALLET_ADD
            self.sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
        }
    }
}

extension MainController:NodeServiceDelegate{
    
    func onBalance(_ planet: Planet, _ balance: String) {
        
        if let planet = self.planet{
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            planet.getMainItem()?.balance = balance
            
            bottomMenuLauncher?.planet = planet
            bottomPanelComponent.setPlanet(planet)
            
        }
    }
    
    func onTokenBalance(_ planet: Planet, _ tokenList: [MainItem]) {
        mainAdapter = MainETHAdapter(tableView, tokenList)
        mainAdapter?.delegates.append(self)
        
        footerView.updateUI()
        
        refreshComponent.refreshed()
    }
    
    func onTxList(_ planet: Planet, _ txList: [Tx]) {
        txAdapter = TxAdapter(tableView, txList)
        txAdapter?.delegates.append(self)
        
        saveTx(txList)
        
        footerView.updateUI()
        
        refreshComponent.refreshed()
    }
}
