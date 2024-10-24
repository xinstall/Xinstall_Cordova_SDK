package io.xinstall.cordova;// TOM

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.xinstall.XINConfiguration;
import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;
import com.xinstall.model.XAppError;

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
    private XAppData wakeupAppData = null;
    private XAppError wakeupAppError = null;

    private Intent wakeupIntent = null;
    private Activity wakeupActivity = null;

    private boolean hasCallInit = false;
    private boolean initialized = false;
    private boolean registerWakeup = false;
    private Integer wakeupType = 0;

    private static final Handler UIHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();
        getWakeUpParams(cordova.getActivity(),cordova.getActivity().getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        getWakeUpParams(cordova.getActivity(),intent);
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        Log.d(XinstallPlugin,"execute  action =" + action);

        if (TextUtils.isEmpty(action)) {
            return false;
        }

        if ("getInstallParams".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    getInstallParams(args, callbackContext);
                }
            });
            return true;
        } else if ("registerWakeUpHandler".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    registerWakeUpHandler(callbackContext);
                }
            });
            return true;
        } else if ("registerWakeUpDetailHandler".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    registerWakeUpDetailHandler(callbackContext);
                }
            });
            return true;
        } else if ("reportRegister".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    reportRegister(callbackContext);
                }
            });

            return true;
        } else if ("reportEffectEvent".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    reportEffectEvent(args, callbackContext);
                }
            });
            return true;
        } else if ("reportShareByXinShareId".equals(action)) {
			runInUIThread(new Runnable() {
				@Override
				public void run() {
				    reportShareByXinShareId(args, callbackContext);
				}
			});
			return true;
		} else if ("initNoAd".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    initNoAd();
                }
            });
            return true;
        } else if ("initWithAd".equals(action)){
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    initWithAd(args,callbackContext);
                }
            });
			return true;
		} else if ("setLog".equals(action)) {
            runInUIThread(new Runnable() {
                @Override
                public void run() {
                    setLog(args);
                }
            });
            return true;
        }
        return false;
    }

    private  static void runInUIThread(Runnable runnable) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            // 当前线程为UI主线程
            runnable.run();
        } else {
            UIHandler.post(runnable);
        }
    }

    protected void setLog(CordovaArgs args) {
        if (args != null && !args.isNull(0)) {
            Log.d(XinstallPlugin,"setLog");
            boolean isOpen = args.optBoolean(0);
            XInstall.setDebug(isOpen);
        }
    }

    protected void initNoAd() {
		hasCallInit = true;
        Log.d(XinstallPlugin,"init");
        XInstall.init(cordova.getContext());
		initialized();
    }
	
	protected void initWithAd(CordovaArgs args, final CallbackContext callbackContext) {
		hasCallInit = true;
		Log.d(XinstallPlugin,"initWithAd");
		boolean adEnable = false;
		if (args != null && !args.isNull(0)) {
			adEnable = args.optBoolean(0);
		}
		String oaid = "";
		if (args != null && !args.isNull(1)) {
		    oaid = args.optString(1);
        }
		String gaid = "";
		if (args != null && !args.isNull(2)) {
		    gaid = args.optString(2);
        }
		boolean isPremission = true;
		if (args != null && !args.isNull(3)) {
		    isPremission = args.optBoolean(3);
        }

		final XINConfiguration configuration = XINConfiguration.Builder().adEnable(true);
		if (!"".equals(gaid)) {
		    configuration.gaid(gaid);
        }
        if (!"".equals(oaid)) {
            configuration.oaid(oaid);
        }

        if (isPremission) {
            XInstall.initWithPermission(cordova.getContext(), configuration, new Runnable() {
                @Override
                public void run() {
                    initialized();
					callbackContext.success();
                }
            });
        } else {
            XInstall.init(cordova.getContext(),configuration);
            initialized();
			callbackContext.success();
        }
	}

    private void initialized() {
        initialized = true;
        if (wakeupIntent != null && wakeupActivity != null) {
            if (wakeupType == 1) {
                XInstall.getWakeUpParam(wakeupActivity, wakeupIntent, new XWakeUpAdapter() {
                    @Override
                    public void onWakeUp(XAppData xAppData) {
                        if (xAppData != null) {

                            JSONObject jsonObject = xAppData.toJsonObject();

                            Log.d(XinstallPlugin, jsonObject.toString());
                            if (!registerWakeup) {
                                Log.d(XinstallPlugin, "没有注册 wakeupCallback");
                                wakeupAppData = xAppData;
                                wakeupAppError = null;
                                return;
                            }

                            PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                            result.setKeepCallback(true);
                            wakeupCallbackContext.sendPluginResult(result);
                        } else {
                            if (!registerWakeup) {
                                Log.d(XinstallPlugin, "没有注册 wakeupCallback");
                                wakeupAppData = null;
                                wakeupAppError = null;
                                return;
                            }
                            PluginResult result = new PluginResult(PluginResult.Status.OK);
                            result.setKeepCallback(true);
                            wakeupCallbackContext.sendPluginResult(result);
                        }
                    }
                });
            } else if (wakeupType == 2) {
                XInstall.getWakeUpParamEvenErrorAlsoCallBack(wakeupActivity, wakeupIntent, new XWakeUpAdapter() {
                    @Override
                    public void onWakeUpFinish(XAppData xAppData, XAppError xAppError) {
                        super.onWakeUpFinish(xAppData, xAppError);
                        JSONObject jsonObject = toJsonObjectHasError(xAppData,xAppError);

                        Log.d(XinstallPlugin, jsonObject.toString());
                        if (!registerWakeup) {
                            Log.d(XinstallPlugin, "没有注册 wakeupDetailCallback");
                            wakeupAppData = xAppData;
                            wakeupAppError = xAppError;
                            return;
                        }

                        PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                        result.setKeepCallback(true);
                        wakeupCallbackContext.sendPluginResult(result);
                    }
                });
            }

        }
    }

    private void getWakeUpParams(Activity activity, Intent intent) {
        if (initialized) {
            Log.d(XinstallPlugin,"getWakeUpParams  intent : " + intent.getDataString());
            if (wakeupType == 1) {
                XInstall.getWakeUpParam(activity, intent, new XWakeUpAdapter() {
                    @Override
                    public void onWakeUp(XAppData xAppData) {
                        if (xAppData != null) {

                            JSONObject jsonObject = xAppData.toJsonObject();

                            Log.d(XinstallPlugin, jsonObject.toString());
                            if (!registerWakeup) {
                                Log.d(XinstallPlugin, "没有注册 wakeupCallback");
                                wakeupAppData = xAppData;
                                wakeupAppError = null;
                                return;
                            }

                            PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                            result.setKeepCallback(true);
                            wakeupCallbackContext.sendPluginResult(result);
                        } else {
                            if (!registerWakeup) {
                                Log.d(XinstallPlugin, "没有注册 wakeupCallback");
                                wakeupAppData = null;
                                wakeupAppError = null;
                                return;
                            }
                            PluginResult result = new PluginResult(PluginResult.Status.OK);
                            result.setKeepCallback(true);
                            wakeupCallbackContext.sendPluginResult(result);
                        }
                    }
                });
            } else {
                XInstall.getWakeUpParamEvenErrorAlsoCallBack(activity, intent, new XWakeUpAdapter() {
                    @Override
                    public void onWakeUpFinish(XAppData xAppData, XAppError xAppError) {
                        super.onWakeUpFinish(xAppData, xAppError);
                        JSONObject jsonObject = toJsonObjectHasError(xAppData,xAppError);

                        Log.d(XinstallPlugin, jsonObject.toString());
                        if (!registerWakeup) {
                            Log.d(XinstallPlugin, "没有注册 wakeupDetailCallback");
                            wakeupAppData = xAppData;
                            wakeupAppError = xAppError;
                            return;
                        }

                        PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                        result.setKeepCallback(true);
                        wakeupCallbackContext.sendPluginResult(result);
                    }
                });
            }

        } else {
            wakeupIntent = intent;
            wakeupActivity = activity;
        }


    }

    protected void getInstallParams(CordovaArgs args, final  CallbackContext callbackContext) {
        int timeout = 0;
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

    protected void reportRegister(final CallbackContext callbackContext) {
        Log.d(XinstallPlugin, "reportRegister");
        XInstall.reportRegister();
    }

    protected void reportEffectEvent(CordovaArgs args, final CallbackContext callbackContext) {
        if (args != null && !args.isNull(0) && !args.isNull(1)) {
            String eventId = args.optString(0);
            long eventValue = args.optLong(1);

            if (eventId.length() == 0) {
                Log.d(XinstallPlugin,"eventId 参数不得为空");
                return;
            }

            if (eventValue == 0) {
                Log.d(XinstallPlugin,"eventValue 参数不得为空");
                return;
            }

            Log.d(XinstallPlugin, "reportEffectEvent # eventId:" + eventId + ", eventValue:" + eventValue);
            XInstall.reportEvent(eventId, (int) eventValue);
        }
    }
	
	protected void reportShareByXinShareId(CordovaArgs args, final CallbackContext callbackContext) {
		if (args != null && !args.isNull(0)) {
			String userId = args.optString(0);
			if (userId.length() == 0) {
			    Log.d(XinstallPlugin,"userId 参数不得为空");
			    return;
            }
			Log.d(XinstallPlugin, "reportShareByXinShareId # userId:" + userId + ", userId:" + userId);
			XInstall.reportShareByXinShareId(userId);
		}
	}

    protected void registerWakeUpHandler(CallbackContext callbackContext) {
        if (!hasCallInit) {
            Log.d(XinstallPlugin,"未执行SDK 初始化方法, SDK 需要手动初始化(初始方法为 init 和 initWithAd !)");
            return;
        }

        if (wakeupType == 2) {
            Log.d(XinstallPlugin, "registerWakeup 与 registerWakeupDetail 为互斥方法，择一选择使用");
        }

        wakeupType = 1;
        
        //只能注册一个回调
        registerWakeup = true;
        this.wakeupCallbackContext = callbackContext;

        if (wakeupCallbackContext != null && wakeupAppData != null) {
            JSONObject result = wakeupAppData.toJsonObject();
            PluginResult resultOfPlugin = new PluginResult(PluginResult.Status.OK, result);
            resultOfPlugin.setKeepCallback(true);
            wakeupCallbackContext.sendPluginResult(resultOfPlugin);
            
        } else {
			PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
			result.setKeepCallback(true);
			callbackContext.sendPluginResult(result);
            getWakeUpParams(cordova.getActivity(),cordova.getActivity().getIntent());
		}
    }

    protected void registerWakeUpDetailHandler(CallbackContext callbackContext) {
        if (!hasCallInit) {
            Log.d(XinstallPlugin,"未执行SDK 初始化方法, SDK 需要手动初始化(初始方法为 init 和 initWithAd !)");
            return;
        }

        if (wakeupType == 1) {
            Log.d(XinstallPlugin, "registerWakeup 与 registerWakeupDetail 为互斥方法，择一选择使用");
        }

        wakeupType = 2;

        //只能注册一个回调
        registerWakeup = true;
        this.wakeupCallbackContext = callbackContext;

        if (wakeupCallbackContext != null && (wakeupAppData != null || wakeupAppError != null)) {
            JSONObject result = toJsonObjectHasError(wakeupAppData,wakeupAppError);
            PluginResult resultOfPlugin = new PluginResult(PluginResult.Status.OK, result);
            resultOfPlugin.setKeepCallback(true);
            wakeupCallbackContext.sendPluginResult(resultOfPlugin);
        } else {
            PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
            getWakeUpParams(cordova.getActivity(),cordova.getActivity().getIntent());
        }
    }

    private JSONObject toJsonObjectHasError(XAppData xAppData, XAppError xAppError) {

        JSONObject wakeUpData = new JSONObject();
        if (xAppData != null) {
            wakeUpData = xAppData.toJsonObject();
        }
        JSONObject error = new JSONObject();
        if (xAppError != null) {
            try {
                error.put("errorType",xAppError.getErrorCode());
                error.put("errorMsg",xAppError.getErrorMsg());
            } catch (Exception e) {

            }
        }
        JSONObject result = new JSONObject();
        try {
            result.put("wakeUpData",wakeUpData);
            result.put("error",error);
        } catch (Exception e) {

        }
        return  result;
    }
}

