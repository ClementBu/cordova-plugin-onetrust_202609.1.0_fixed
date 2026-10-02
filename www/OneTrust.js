var exec = require('cordova/exec');
const pluginName = "OneTrust"

var exports = {
  //Initialize Methods
    startSDK:(storageLocation, appId, languageCode, params, success, error) => {
      exec(success, error, pluginName, 'startSDK', [storageLocation, appId, languageCode, params])
    },
    //UI Methods
    showBannerUI: () => {
      exec(null, null, pluginName, 'showBannerUI')
    },
    showPreferenceCenterUI: () => {
      exec(null, null, pluginName, 'showPreferenceCenterUI')
    },
    showConsentUI: (OTDevicePermission, success, error) => {
      exec(success, error, pluginName, 'showConsentUI', [OTDevicePermission])
    },
    //Query for Consent
    getConsentStatusForCategory: (categoryId, success, error) => {
      exec(success, error, pluginName, 'getConsentStatusForCategory', [categoryId])
    },
    //Boolean banner show methods
    shouldShowBanner: (success, error) => {
      exec(success, error, pluginName, 'shouldShowBanner')
    },
    isBannerShown: (success, error) => {
      exec(success, error, pluginName, 'isBannerShown')
    },
    //Listen for changes
    observeChanges: (categoryId) => {
      exec(null, null, pluginName, 'observeChanges', [categoryId])
    },
    stopObservingChanges: (categoryId) => {
      exec(null, null, pluginName, 'stopObservingChanges', [categoryId])
    },
    //Get OneTrust-set UUID
    getCachedIdentifier: (success, error) =>{
      exec(success, error, pluginName, 'getCachedIdentifier')
    },
    //BYOUI Methods
    getPreferenceCenterData: (success, error) => {
      exec(success,error, pluginName, 'getPreferenceCenterData')
    },
    getBannerData: (success, error) => {
      exec(success, error, pluginName, 'getBannerData')
    },
    //Get JS to inject to webview
    getOTConsentJSForWebview:(success, error) => {
      exec(success, error, pluginName, 'getOTConsentJSForWebview')
    },

    //Force close UI
    dismissUI: () =>{
      exec(null, null, pluginName, 'dismissUI')
    },

    getOTGoogleConsentModeData: (success, error) => {
      exec(success,error, pluginName, 'getOTGoogleConsentModeData')
    },

    fetchBannerCmpApiData: (success, error) => {
      exec(success, error, pluginName, 'fetchBannerCmpApiData')
    },

    fetchPreferencesCmpApiData: (success, error) => {
      exec(success, error, pluginName, 'fetchPreferencesCmpApiData')
    },

    fetchVendorsCmpApiData: (success, error) => {
      exec(success, error, pluginName, 'fetchVendorsCmpApiData')
    },

    renameProfile: (fromIdentifier, toIdentifier, success, error) => {
      exec(success, error, pluginName, 'renameProfile', [fromIdentifier, toIdentifier])
    },

    clearOTSDKData: () =>{
      exec(null, null, pluginName, 'clearOTSDKData')
    },

    devicePermission: Object.freeze({idfa:0})
  }
  
module.exports = exports
