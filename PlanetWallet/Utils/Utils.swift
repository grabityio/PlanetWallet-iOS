//
//  Utils.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import EthereumKit

struct Utils {
    
    static let shared = Utils()
    
    private init() { }
    
    //MARK: - System Version
    ///Usages : SYSTEM_VERSION_EQUAL_TO("7.0")
    func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedSame
    }
    
    ///Usages : SYSTEM_VERSION_GREATER_THAN("7.0")
    func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedDescending
    }
    
    ///Usages : SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("7.0")
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedAscending
    }
    
    ///Usages : SYSTEM_VERSION_LESS_THAN("7.0")
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
    }
    
    ///Usages : SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("7.0")
    func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedDescending
    }
    
    
    //MARK: - Valid
    func isValid(planetName: String) -> Bool {
        let regex = ".*[^A-Za-z0-9_].*"
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            if regex.firstMatch(in: planetName, options: [], range: NSMakeRange(0, planetName.count)) != nil {
                return false
            }
            else {
                return true
            }
        }
        catch {
            return false
        }
    }
    
    func isValid(email: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch {
            returnValue = false
        }
        
        return  returnValue
    }
    
    func isValid(phone: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    //MARK: - Coin Address
    ///0xf291b69799516156fAA7F9ed4c39536335Ab797A -> 0xf291...797A
    ///3Gvgi1WpEZ73CNmQviecrnyiWrnqRhjJm1 -> 3Gvg...jJm1
    func trimAddress(_ addr: String) -> String {
        
        let prefix = addr[0..<2]
        if prefix == "0x" { //ETH
            return addr[0..<6] + "..." + addr[addr.count-4..<addr.count]
        }
        else { //Others
            return addr[0..<4] + "..." + addr[addr.count-4..<addr.count]
        }
    }
    
    //MARK: - Clipboard
    func copyToClipboard(_ str: String) {
        UIPasteboard.general.string = str
    }
    
    func getClipboard() -> String? {
        return UIPasteboard.general.string
    }
    
    //MARK: - Unit
    /*
    //ETH <-> GWEI
    func gweiToETH(_ gwei: Int) -> Double {
        return Double(gwei) / pow(10, 9)
    }
    
    func gweiToETH(_ gwei: Int) -> String? {
        let eth = Double(gwei) / pow(10, 9)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 9
        
        return formatter.string(from: eth as NSNumber)
    }
    
    func gweiToETH(_ gwei: Int) -> Double? {
        let eth = Double(gwei) / pow(10, 9)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 9
        
        return formatter.number(from: "\(eth)") as? Double
    }
    
    func ethToGWEI(_ eth: Double) -> Double {
        
        return eth * pow(10, 9)
    }
    
    //ETH <-> WEI
    func ethToWEI(_ eth: Double) -> BigInt? {
        let wei = eth * pow(10, 18)
        
        return BigInt(exactly: wei)
    }
    
    func ethToWEI(_ eth: Decimal) -> String {
        let wei = eth * pow(10, 18)
        return wei.toString()
    }
    
    func ethToWEI(_ eth: Double) -> String? {
        
        if let wei: BigInt = ethToWEI(eth) {
            return String(wei)
        }
        else {
            return nil
        }
    }
    
    func weiToETH(_ wei: Int, maximumFraction: Int = 8) -> String? {
        let eth = Double(wei) / pow(10, 18)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFraction
        
        return formatter.string(from: NSNumber(value: eth))
    }
    */
    //MARK: - Date
    func changeDateFormat(date: String, beforFormat: DateFormat, afterFormat: DateFormat) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = beforFormat.rawValue
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = afterFormat.rawValue
        
        //2014-05-22T03:46:25Z
        if let beforeDate = dateFormatterGet.date(from: date) {//2016-02-29 12:24:26
            return dateFormatterPrint.string(from: beforeDate)
        } else {
            return nil
        }
    }
    
    func changeDateFormat(date: Date, afterFormat: DateFormat) -> String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = afterFormat.rawValue
        
        return dateFormatterPrint.string(from: date)
    }
    
    func getDateFromString(_ date: String, format: DateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)
    }
    
    func getStringFromDate(_ date: Date, format: DateFormat) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
    
    func getTimeInterval(date: String, format: DateFormat) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)?.timeIntervalSince1970
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.BASIC.rawValue
        
        return formatter.string(from: Date())
    }
    
    //MARK: - Font
    func planetFont(style: FontStyle, size: CGFloat) -> UIFont? {
        
        return UIFont(name: style.rawValue, size: size)
    }
    
    //MARK: - Version
    func getVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    //MARK: - UserDefaults
    func setDefaults(for key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getDefaults<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
    //MARK: - StatusBar
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    //MARK: - WIF
    func convertPrivateKeyToWIF(_ privKey: String,_ compress:Bool = true ) -> String? {
        if let privKeyData = privKey.hexadecimal, let prefix = Data(hexString: "0x80") {
            var wif = prefix + privKeyData
            if( compress ){
                wif += Data(hexString: "0x01")!
            }
            let doubleSHA256 = Crypto.sha256(Crypto.sha256(wif))
            let checkSum = doubleSHA256.prefix(4)
            wif += checkSum
            return String(base58Encoding: wif)
        }
        return nil
    }
    
    func convertWIFToPrivateKey(_ wifPrivKey:String )->String?{
        if let decodePrivKey = Data(base58Decoding: wifPrivKey){
            
            if wifPrivKey.first == "L" || wifPrivKey.first == "K" {
                
                let checkSum = decodePrivKey.subdata(in: Range(NSMakeRange(decodePrivKey.count - 4, 4))!)
                var data = decodePrivKey.subdata(in: Range(NSMakeRange(0, decodePrivKey.count - 4))!)
                
                data = Crypto.sha256(Crypto.sha256(data))
                if data.subdata(in: Range(NSMakeRange(0, 4))!).hexString == checkSum.hexString{

                    var privateKey = decodePrivKey.subdata(in: Range(NSMakeRange(0, decodePrivKey.count - 4))!)
                    if( privateKey.count == 34 && privateKey.last == 0x01 ){
                        privateKey = privateKey.subdata(in: Range(NSMakeRange(1, privateKey.count - 2))!)
                    }
                    return privateKey.hexString
                }
                
            }
            else if wifPrivKey.first == "5" {
                
                let checkSum = decodePrivKey.subdata(in: Range(NSMakeRange(decodePrivKey.count - 4, 4))!)
                var data = decodePrivKey.subdata(in: Range(NSMakeRange(0, decodePrivKey.count - 4))!)
                data = Crypto.sha256(Crypto.sha256(data))
                if data.subdata(in: Range(NSMakeRange(0, 4))!).hexString == checkSum.hexString{
                    let privateKey = decodePrivKey.subdata(in: Range(NSMakeRange(1, decodePrivKey.count - 5))!)
                    return privateKey.hexString
                }
                
            }
        }
        return nil
    }
    
    
    //MARK: - Network
    func showNetworkErrorToast(json: [String: Any]) {
        if let errorMsg = json["errorMsg"] as? String
        {
            Toast(text: errorMsg).show()
        }
    }
}

extension Utils {
    enum FontStyle: String {
        case BOLD = "WorkSans-Bold"
        case SEMIBOLD = "WorkSans-SemiBold"
        case MEDIUM = "WorkSans-Medium"
        case REGULAR = "WorkSans-Regular"
    }
}

extension Utils {
    /*
     Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
     09/12/2018                        --> MM/dd/yyyy
     09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
     Sep 12, 2:11 PM                   --> MMM d, h:mm a
     September 2018                    --> MMMM yyyy
     Sep 02, 2018                      --> MMM dd, yyyy
     Sep 2, 2018                       --> MMM d, yyyy
     Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
     2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
     12.09.18                          --> dd.MM.yy
     10:41:02.112                      --> HH:mm:ss.SSS
     Sep 02, 14:11                     --> MMM dd,HH:mm
     */
    enum DateFormat: String {
        ///2018-09-12 14:11:54
        case BASIC = "yyyy-MM-dd HH:mm:ss"
        ///2018-09-12T14:11:54+0000
        case BASIC_TZ = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        ///Sep 02, 2018
        case MMMddyyyy = "MMM dd, yyyy"
        ///Sep 02, 14:11
        case MMMddHHmm = "MMM dd, HH:mm"
        ///2019. 06. 13 13:05:10
        case yyyyMMddHHmmss = "yyyy. MM. dd HH:mm:ss"
        ///2019. 02. 01
        case yyyyMMdd = "yyyy. MM. dd"
    }
}
