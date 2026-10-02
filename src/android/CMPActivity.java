package com.onetrust.cordova;

import androidx.appcompat.app.AppCompatActivity;

import android.graphics.Color;
import android.os.Bundle;
import android.view.Window;

import com.onetrust.otpublishers.headless.Public.OTEventListener;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.OTUIDisplayReason.OTUIDisplayReason;


public class CMPActivity extends AppCompatActivity {
    OTPublishersHeadlessSDK ot;
    Integer layout;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        layout = this.getResources().getIdentifier("activity_c_m_p","layout", getPackageName());
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(layout);

        try {
            this.getWindow().getDecorView().setBackgroundColor(Color.TRANSPARENT);
        } catch (Exception e) {
            e.printStackTrace();
        }

        ot = new OTPublishersHeadlessSDK(this);
        addEventListeners();

        switch (this.getIntent().getIntExtra("UIType",-1)){
            case 0:
                ot.showBannerUI(this);
                break;
            case 1:
                ot.showPreferenceCenterUI(this);
                break;
            default:
                endActivity();
        }
    }

    private void endActivity(){
        setResult(RESULT_OK, this.getIntent());
        CMPActivity.super.finish();
    }

    private void addEventListeners(){
        String emptyPayload = "{}";
        ot.addEventListener(new OTEventListener() {
            @Override
            public void onShowBanner(OTUIDisplayReason otuiDisplayReason) {

            }

            @Override
            public void onHideBanner() { 

            }

            @Override
            public void onBannerClickedAcceptAll() {
                
            }

            @Override
            public void onBannerClickedRejectAll() {
                
            }

            @Override
            public void onShowPreferenceCenter(OTUIDisplayReason otuiDisplayReason) {

            }

            @Override
            public void onHidePreferenceCenter() {
                
            }

            @Override
            public void onPreferenceCenterAcceptAll() {
                
            }

            @Override
            public void onPreferenceCenterRejectAll() {
                
            }

            @Override
            public void onPreferenceCenterConfirmChoices() {
                
            }

            @Override
            public void onShowVendorList() {

            }

            @Override
            public void onHideVendorList() {

            }

            @Override
            public void onVendorConfirmChoices() {

            }

            @Override
            public void onVendorListVendorConsentChanged(String s, int i) {

            }

            @Override
            public void onVendorListVendorLegitimateInterestChanged(String s, int i) {

            }

            @Override
            public void onPreferenceCenterPurposeConsentChanged(String s, int i) {

            }

            @Override
            public void onPreferenceCenterPurposeLegitimateInterestChanged(String s, int i) {

            }

            @Override
            public void allSDKViewsDismissed(String interactionType){
                endActivity();
            }
        });
    }
}