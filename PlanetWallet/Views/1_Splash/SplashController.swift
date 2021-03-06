//
//  ViewController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie
import ObjectMapper
import Firebase
import BigInt

class SplashController: PlanetWalletViewController {
    
    private var isPinRegistered = true
    private var isSync = false
    
    private let animationView = AnimationView()
    private var planet : Planet?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APP_DELEGATE.messagingDelegates.append(self)
    }
    
    override func viewInit() {
        super.viewInit()
        
        switch currentTheme {
        case .DARK:         self.animationView.animation = Animation.named("splash_03_bk")
        case .LIGHT:        self.animationView.animation = Animation.named("splash_03_wh")
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                                     animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor),
                                     animationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 38),
                                     animationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -38)])
    }
    
    override func setData() {
        super.setData()
        
        Get(self).action(Route.URL("version","ios"), requestCode: 0, resultCode: 0, data: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { (isSuccess) in
            if isSuccess {
                self.moveEntryPoint()
            }
        }
    }
    
    //MARK: - Private
    private func getDeviceKey() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                Toast(text: error.localizedDescription).show()
            } else if let result = result {
                if let fcmToken: String = Utils.shared.getDefaults(for: Keys.Userdefaults.FCM_TOKEN ){
                    if fcmToken != result.token {
                        Utils.shared.setDefaults(for: Keys.Userdefaults.FCM_TOKEN, value: result.token)
                        Post(self).action(Route.URL("device","ios"), requestCode: 0, resultCode: 0, data: ["device_token":result.token]);
                        return
                    }
                }else{
                    Utils.shared.setDefaults(for: Keys.Userdefaults.FCM_TOKEN, value: result.token)
                    Post(self).action(Route.URL("device","ios"), requestCode: 0, resultCode: 0, data: ["device_token":result.token]);
                    return
                }
                
                if let deviceKeyData = KeyStore.shared.getValue(key: Keys.Userdefaults.DEVICE_KEY),
                    let deviceKey = String(data: deviceKeyData, encoding: .utf8)
                {
                    DEVICE_KEY = deviceKey
                }
            }
        }
    }
    
    private func moveEntryPoint() {
        
        if DEVICE_KEY == "" || !isSync {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.moveEntryPoint()
            }
        }else{
            
            guard let _: String = Utils.shared.getDefaults(for: Keys.Userdefaults.PINCODE) else {
                isPinRegistered = false
                sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION,
                           userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION])
                return
            }
            
            if isPinRegistered {
                sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION,
                           userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION])
            }
            
        }
    }

    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard success else { return }
        
        guard let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if isSuccess {
            if let results = returnVo.result as? [String: Any], let versionStr = results["version"] as? String, let forceUpdate = results["force_update"] as? String, let localVersionStr = Utils.shared.getVersion() {
                
                RECENT_VERSION = versionStr
                
                if let version = Decimal(string: versionStr), let localVersion = Decimal(string: localVersionStr) {
                    
                    if version > localVersion && forceUpdate == "Y" {
                        Toast(text: "splash_force_update".localized, duration: 5.0).show()
                        return
                    }
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
        
        SyncManager.shared.syncPlanet( self )
        getDeviceKey()
    }
}

extension SplashController: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        if let device_key = remoteMessage.appData["device_key"] as? String ,
            let deviceKeyData = device_key.data(using: .utf8)
        {
            KeyStore.shared.setValue(key: Keys.Userdefaults.DEVICE_KEY, data: deviceKeyData)
        }
        
        if let deviceKeyData = KeyStore.shared.getValue(key: Keys.Userdefaults.DEVICE_KEY),
            let deviceKey = String(data: deviceKeyData, encoding: .utf8)
        {
            DEVICE_KEY = deviceKey
        }
    }
}

extension SplashController: SyncDelegate {
    func sync(_ syncType: SyncType, didSyncComplete complete: Bool, isUpdate: Bool) {
        
        isSync = true
    }
}
