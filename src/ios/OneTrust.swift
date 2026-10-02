import Foundation
import OTPublishersHeadlessSDK
import AppTrackingTransparency

@objc(OneTrust) class OneTrust : CDVPlugin{
    // MARK: Properties
    var OneTrustVC:UIViewController?
    @objc(startSDK:)
    func startSDK(_ command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        var initParams:OTSdkParams? = nil
        //Set up view controller
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.keyWindow?.rootViewController{
                self.OneTrustVC = vc
                OTPublishersHeadlessSDK.shared.addEventListener(self)
                OTPublishersHeadlessSDK.shared.setupUI(vc)
            }
        }
        
        //Exit from startSDK if any of the first three args are not supplied
        guard let storageLocation = command.argument(at: 0) as? String,
              let domainIdentifier = command.argument(at:1) as? String,
              let languageCode = command.argument(at: 2) as? String else {
            returnToCordova(pluginResult: pluginResult, command: command)
            return
        }
        
        //Retrieve params data from Cordova if supplied
        if let paramsData = command.argument(at: 3) as? NSDictionary{
            initParams = buildSDKParams(withParamsObject: paramsData)
        }

        OTPublishersHeadlessSDK.shared.startSDK(storageLocation: storageLocation,
                                                domainIdentifier: domainIdentifier,
                                                languageCode: languageCode,
                                                params: initParams){(otResponse) in
            if(otResponse.status){
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: otResponse.status)
            }else{
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: otResponse.error.debugDescription)
            }
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    private func buildSDKParams(withParamsObject params:NSDictionary) -> OTSdkParams{
        var profileSyncParams:OTProfileSyncParams? = nil
        //create profileSyncParams object
        if let syncParamsData = params.value(forKey: "syncParams") as? [String:String],
           let identifer = syncParamsData["identifier"],
           let jwt = syncParamsData["syncProfileAuth"]{
            profileSyncParams = OTProfileSyncParams()
            profileSyncParams!.setIdentifier(identifer)
            profileSyncParams!.setSyncProfileAuth(jwt)
            profileSyncParams!.setSyncProfile("true")
        }
        
        //get country code and region code if they exist
        let countryCode = params.value(forKey: "countryCode") as? String
        let regionCode = params.value(forKey: "regionCode") as? String
        
        //create OTParams object with country and region code. Both are optionals.
        let OTParams = OTSdkParams(countryCode: countryCode, regionCode: regionCode)
        
        //Add profile sync params to the OTParams object only if it is != nil
        if let profileSyncParams = profileSyncParams{
            OTParams.setProfileSyncParams(profileSyncParams)
            OTParams.setShouldCreateProfile("true")
        }

        //If setAPIVersion is defined, add it to the params object.
        if let overrideVersion = params.value(forKey: "setAPIVersion") as? String{
            OTParams.setSDKVersion(overrideVersion)
        }
        
        return OTParams
    }
    
    @objc(showBannerUI:)
    func showBannerUI(_ command: CDVInvokedUrlCommand){
        OTPublishersHeadlessSDK.shared.showBannerUI()
        
        self.returnToCordova(pluginResult: CDVPluginResult(status: CDVCommandStatus_OK), command: command)
    }
    
    @objc(showPreferenceCenterUI:)
    func showPreferenceCenterUI(_ command: CDVInvokedUrlCommand){
        OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
        self.returnToCordova(pluginResult: CDVPluginResult(status: CDVCommandStatus_OK), command: command)
    }
    
    @objc(showConsentUI:)
    func showConsentUI(_ command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        /*If not running iOS 14+, we'll return to Cordova with a -1. Android
            does the same as it's not a supported platform for ATT, but we still
            want to resolve the promise.
        */
        guard #available(iOS 14, *) else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: -1)
            self.returnToCordova(pluginResult: pluginResult, command: command)
            return
        }
        //App Permission Type Map
        func appPermissionType(fromInt raw:Int) -> AppPermissionType?{
            switch raw{
            case 0:
                return .idfa
            default:
                return nil
            }
        }
        //make sure that we have a permission int, that that translates to a permission, and that we have a VC
        if let permissionInt = command.argument(at: 0) as? Int,
           let permissionType = appPermissionType(fromInt: permissionInt),
           let vc = OneTrustVC{
               /*Once we load the pre-prompt, we'll pass back the status of the prompt in the 
                 completion handler. We're just going to send this back as a String. If ATT has already
                 been shown, this will just resolve immediately with the user's previously-selected status.
                */
            OTPublishersHeadlessSDK.shared.showConsentUI(for: permissionType, from: vc){ [weak self] in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: self?.getATTStatusAsString())
                self?.returnToCordova(pluginResult: pluginResult, command: command)
            }
        }else{
            self.returnToCordova(pluginResult: pluginResult, command: command)
        }  
    }
    
    @objc(shouldShowBanner:)
    func shouldShowBanner(_ command: CDVInvokedUrlCommand){
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: OTPublishersHeadlessSDK.shared.shouldShowBanner())
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(isBannerShown:)
    func isBannerShown(_ command:CDVInvokedUrlCommand){
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: OTPublishersHeadlessSDK.shared.isBannerShown())
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(getConsentStatusForCategory:)
    func getConsentStatusForCategory(_ command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let category = command.argument(at: 0) as? String{
            let status = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: category)
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: Int(status))
        }
        
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(observeChanges:)
    func observeChanges(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let category = command.argument(at: 0) as? String{
            if category == "OTConsentUpdated" {
                NotificationCenter.default.addObserver(self, selector: #selector(otConsentUpdated(_:)), name: Notification.Name(category), object: nil)
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(consentChanged(_:)), name: Notification.Name(category), object: nil)
            }
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(stopObservingChanges:)
    func stopObservingChanges(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let category = command.argument(at: 0) as? String{
            NotificationCenter.default.removeObserver(self, name: Notification.Name(category), object: nil)
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }
        
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(addCustomStyles:)
    func addCustomStyles(_ command:CDVInvokedUrlCommand){
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Command addCustomStyling not used on iOS")
        print("Command addCustomStyling not used on iOS")
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(getCachedIdentifier:)
    func getCachedIdentifier(_ command:CDVInvokedUrlCommand){
        let identifier = OTPublishersHeadlessSDK.shared.currentActiveProfile
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: identifier)
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(getBannerData:)
    func getBannerData(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let bannerData = OTPublishersHeadlessSDK.shared.getBannerData(){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: bannerData)
        }
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(getPreferenceCenterData:)
    func getPreferenceCenterData(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let bannerData = OTPublishersHeadlessSDK.shared.getPreferenceCenterData(){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: bannerData)
        }
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }

    @objc(getOTGoogleConsentModeData:)
    func getOTGoogleConsentModeData(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        let gcmOTData = OTPublishersHeadlessSDK.shared.getOTGoogleConsentModeData()
        let analyticsStorageValue = gcmOTData.consentType.analyticsStorage == .granted ? "granted" : "denied"
        let addStorageValue = gcmOTData.consentType.adStorage == .granted ? "granted" : "denied"
        let adUserDataValue = gcmOTData.consentType.adUserData == .granted ? "granted" : "denied"
        let adPersonalizationValue = gcmOTData.consentType.adPersonalization == .granted ? "granted" : "denied"
        let functionalityStorageValue = gcmOTData.consentType.functionalityStorage == .granted ? "granted" : "denied"
        let personalizationStorageValue = gcmOTData.consentType.personalizationStorage == .granted ? "granted" : "denied"
        let securityStorageValue = gcmOTData.consentType.securityStorage == .granted ? "granted" : "denied"
        
            let gcmOTDataJSONObject: [String: String] = [ 
                "analytics_storage": analyticsStorageValue,
                "ad_storage": addStorageValue,
                "ad_user_data": adUserDataValue,
                "ad_personalization": adPersonalizationValue,
                "functionality_storage": functionalityStorageValue,
                "personalization_storage": personalizationStorageValue,
                "security_storage": securityStorageValue
            ]

        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: gcmOTDataJSONObject)
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(getOTConsentJSForWebview:)
    func getOTConsentJSForWebview(_ command:CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        if let js = OTPublishersHeadlessSDK.shared.getOTConsentJSForWebView(){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: js)
        }
        self.returnToCordova(pluginResult: pluginResult, command: command)
    }
    
    @objc(dismissUI:)
    func dismissUI(_ command:CDVInvokedUrlCommand){
        OTPublishersHeadlessSDK.shared.dismissUI()
        self.returnToCordova(pluginResult: CDVPluginResult(status: CDVCommandStatus_OK), command: command)
    }
    
    //MARK: Internal Methods
    
    private func emit(eventName:String, payload:String="{}"){
        DispatchQueue.main.async {
            self.webViewEngine.evaluateJavaScript("cordova.fireDocumentEvent('\(eventName)',\(payload));", completionHandler: nil)
        }
    }
    
    @objc private func consentChanged(_ notification:Notification){
        if let consentStatus = notification.object as? Int{
            let ex = "cordova.fireDocumentEvent('\(notification.name.rawValue)',{categoryId:'\(notification.name.rawValue)', consentStatus:\(consentStatus)});"
            DispatchQueue.main.async{
                self.webViewEngine.evaluateJavaScript(ex, completionHandler: nil)
            }
            
        }
        
    }
    
    @objc private func otConsentUpdated(_ notification:Notification){
        let ex = "cordova.fireDocumentEvent('OTConsentUpdated',{});"
        DispatchQueue.main.async{
            self.webViewEngine.evaluateJavaScript(ex, completionHandler: nil)
        }
    }
    
    private func getATTStatusAsString() -> String?{
            guard #available(iOS 14, *) else {return nil}
            let statusMap:[ATTrackingManager.AuthorizationStatus:String] = [.authorized:"authorized", .denied:"denied", .notDetermined:"notDetermined", .restricted:"restricted"]
            let status = statusMap[ATTrackingManager.trackingAuthorizationStatus]
            return status
        }
    
    private func returnToCordova(pluginResult: CDVPluginResult?, command:CDVInvokedUrlCommand){
        if pluginResult != nil{
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    // Add this private helper method
    private func fetchCmpApiData(
        fetcher: (@escaping ([String: Any]?) -> Void) -> Void,
        command: CDVInvokedUrlCommand,
        errorMessage: String
    ) {
        fetcher { response in
            let pluginResult: CDVPluginResult
            if let data = response,
            let jsonData = try? JSONSerialization.data(withJSONObject: data),
            let jsonString = String(data: jsonData, encoding: .utf8) {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonString)
            } else {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: errorMessage)
            }
            self.returnToCordova(pluginResult: pluginResult, command: command)
        }
    }

    @objc(fetchBannerCmpApiData:)
    func fetchBannerCmpApiData(_ command: CDVInvokedUrlCommand) {
        fetchCmpApiData(
            fetcher: OTPublishersHeadlessSDK.shared.fetchBannerCmpApiData,
            command: command,
            errorMessage: "No response from fetchBannerCmpApiData"
        )
    }

    @objc(fetchPreferencesCmpApiData:)
    func fetchPreferencesCmpApiData(_ command: CDVInvokedUrlCommand) {
        fetchCmpApiData(
            fetcher: OTPublishersHeadlessSDK.shared.fetchPreferencesCmpApiData,
            command: command,
            errorMessage: "No response from fetchPreferencesCmpApiData"
        )
    }

    @objc(fetchVendorsCmpApiData:)
    func fetchVendorsCmpApiData(_ command: CDVInvokedUrlCommand) {
        fetchCmpApiData(
            fetcher: OTPublishersHeadlessSDK.shared.fetchVendorsCmpApiData,
            command: command,
            errorMessage: "No response from fetchVendorsCmpApiData"
        )
    }

    @objc(renameProfile:)
    func renameProfile(_ command: CDVInvokedUrlCommand) {
        let fromIdentifier = command.argument(at: 0) as? String
        guard let toIdentifier = command.argument(at: 1) as? String else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "toIdentifier is required")
            self.returnToCordova(pluginResult: pluginResult, command: command)
            return
        }
        
        OTPublishersHeadlessSDK.shared.renameProfile(from: fromIdentifier, to: toIdentifier) { success in
            let pluginResult: CDVPluginResult
            if success {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true)
            } else {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error renaming profile")
            }
            self.returnToCordova(pluginResult: pluginResult, command: command)
        }
    }

    @objc(clearOTSDKData:)
    func clearOTSDKData(_ command: CDVInvokedUrlCommand){
        OTPublishersHeadlessSDK.shared.clearOTSDKData()
        self.returnToCordova(pluginResult: CDVPluginResult(status: CDVCommandStatus_OK), command: command)
    }
}

extension OneTrust:OTEventListener{
    func allSDKViewsDismissed(interactionType: ConsentInteractionType) {
        emit(eventName: "allSDKViewsDismissed")
    }
}
