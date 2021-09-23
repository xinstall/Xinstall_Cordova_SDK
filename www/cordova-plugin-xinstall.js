var exec = require('cordova/exec');

module.exports = {
	
	/**
	 * 不接入广告的初始化方法
	 */
	init: function() {
		function pass() {};
		exec(pass,pass,"XinstallPlugin","initNoAd",[])
	},
	
	initWithAd: function (params,premissedBackBlock) {
		function pass() {};
		
		var adEnable = params.adEnable;
		if (adEnable == null) {
			adEnable = false;
		} 
		
		var oaid = params.oaid;
	    var gaid = params.gaid;
		var isPremission = params.isPremission;
		
		if (premissedBackBlock == null) {
			premissedBackBlock = pass;
		}
			
		var idfa = params.idfa;
		
		exec(premissedBackBlock,pass,"XinstallPlugin","initWithAd",[adEnable,oaid,gaid,isPremission,idfa]);
	} ,
	
	
	setLog: function (isOpen) {
		function pass() {};
		exec(pass,pass,"XinstallPlugin","setLog",[isOpen]);
	},
	
	
    /**
     * 获取安装参数
     * @param onSuccess 成功回调：数据格式为 {'channelCode': 1002, 'data': {'key': 'value'}}
     * @param time 超时时间：整形值，单位秒 注：iOS暂不提供该功能。
     */
    getInstallParams: function (onSuccess, onError, time){
        exec(onSuccess, onError, "XinstallPlugin", "getInstallParams", [time]);
    },

    /**
     * 注册唤醒监听
     */
    registerWakeUpHandler: function(onSuccess, onError){
        exec(onSuccess, onError, "XinstallPlugin", "registerWakeUpHandler", []);
    },

    /**
     * 注册唤醒监听（会返回相关错误）
     */
    registerWakeUpDetailHandler: function(onSuccess, onError){
    	exec(onSuccess, onError, "XinstallPlugin", "registerWakeUpDetailHandler",[]);
    },

    /**
     * 注册统计
     */
    reportRegister: function(){
        function pass() {};
        exec(pass, pass, "XinstallPlugin", "reportRegister", []);
    },

    /**
     * 上报事件
     * @param eventId 事件ID
     * @param eventValue 事件值 (数字类型)
     */
    reportEffectEvent: function(eventId, eventValue){
        function pass() {};
        exec(pass, pass, "XinstallPlugin", "reportEffectEvent", [eventId, eventValue]);
    },
	/**
	 * 分享裂变事件上报
	 * @param userId 用户Id
	 */
	reportShareByXinShareId: function(userId) {
	    function pass() {};
	    exec(pass, pass, "XinstallPlugin", "reportShareByXinShareId",[userId]);
	}
};