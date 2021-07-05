package io.xinstall.cordova;// TOM

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class XinstallPlugin extends CordovaPlugin {
    public static final  String XinstallPlugin = "XinstallPlugin";

    private CallbackContext wakeupCallbackContext = null;

    private boolean isOpenYyb = true;

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();
        init();
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (wakeupCallbackContext != null) {
            getWakeUpParams(cordova.getActivity(),intent, wakeupCallbackContext);
        }
    }



    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        Log.d(XinstallPlugin,"execute  action =" + action);

        if (TextUtils.isEmpty(action)) {
            return false;
        }

        if ("getInstallParams".equals(action)) {
            getInstallParams(args, callbackContext);
            return true;
        } else if ("registerWakeUpHandler".equals(action)) {
            registerWakeUpHandler(callbackContext);
            return true;
        } else if ("reportRegister".equals(action)) {
            reportRegister(callbackContext);
            return true;
        } else if ("reportEffectEvent".equals(action)) {
            reportEffectEvent(args, callbackContext);
            return true;
        } 
		// else if ("openYybWakeUp".equals(action)) {
  //           openYybWakeUp(callbackContext);
  //           return true;
  //       }

        return false;
    }

    protected void init() {
        Log.d(XinstallPlugin,"init");
        XInstall.init(cordova.getContext());
    }

    private void getWakeUpParams(Activity activity, Intent intent, final CallbackContext callbackContext) {
        if ((intent.getCategories() != null  && intent.getCategories().contains(Intent.CATEGORY_LAUNCHER)) && this.isOpenYyb == false) {
            return;
        }

        Log.d(XinstallPlugin,"getWakeUpParams  intent : " + intent.getDataString());
        XInstall.getWakeUpParam(activity, intent, new XWakeUpAdapter() {
            @Override
            public void onWakeUp(XAppData xAppData) {
                if (xAppData != null) {
                    JSONObject jsonObject = xAppData.toJsonObject();

                    PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                } else {
                    PluginResult result = new PluginResult(PluginResult.Status.OK);
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                }
            }
        });
    }

    protected void getInstallParams(CordovaArgs args, final  CallbackContext callbackContext) {
        int timeout = -1;
        if (args != null && !args.isNull(0)) {
            timeout =  args.optInt(0);
        }

        Log.d(XinstallPlugin, "getInstallParams " + timeout + "s");
        XInstall.getInstallParam(new XInstallAdapter() {
            @Override
            public void onInstall(XAppData xAppData) {
                Log.d(XinstallPlugin, "onInstallFinish # " + (xAppData == null ? "XAppData 为 null" : xAppData.toString()));
                if (xAppData != null) {
                    JSONObject jsonObject = xAppData.toJsonObject();
                    callbackContext.success(jsonObject);

                } else {
                    callbackContext.success();
                }
            }
        });
    }

    // protected void openYybWakeUp(final CallbackContext callbackContext) {
    //     this.isOpenYyb = true;
    // }

    protected void reportRegister(final CallbackContext callbackContext) {
        Log.d(XinstallPlugin, "reportRegister");
        XInstall.reportRegister();
    }

    protected void reportEffectEvent(CordovaArgs args, final CallbackContext callbackContext) {
        if (args != null && !args.isNull(0) && !args.isNull(1)) {
            String eventId = args.optString(0);
            long eventValue = args.optLong(1);
            Log.d(XinstallPlugin, "reportEffectEvent # eventId:" + eventId + ", eventValue:" + eventValue);
            XInstall.reportPoint(eventId, (int) eventValue);
        }
    }

    protected void registerWakeUpHandler(CallbackContext callbackContext) {
        //只能注册一个回调
        this.wakeupCallbackContext = callbackContext;
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);

        Intent intent = cordova.getActivity().getIntent();
        if (intent == null)
        {
            return;
        }

        if (intent.getAction().equals(Intent.ACTION_VIEW)) {
            if (TextUtils.isEmpty(intent.getDataString())) {
                return;
            }
        }
        if (wakeupCallbackContext != null) {
            getWakeUpParams(cordova.getActivity(), this.cordova.getActivity().getIntent(), wakeupCallbackContext);
        }
    }
}
