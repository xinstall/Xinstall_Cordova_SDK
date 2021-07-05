var exec = require('cordova/exec');

module.exports = {
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
     * 注册统计
     */
    reportRegister: function(){
        function pass() {};
        exec(pass, pass, "XinstallPlugin", "reportRegister", []);
    },
	
	/**
	 * 开启应用宝功能
	 */
	openYybWakeUp: function() {
	    function pass() {};
	    exec(pass, pass, "XinstallPlugin", "openYybWakeUp", []);
	},

    /**
     * 上报事件
     * @param eventId 事件ID
     * @param eventValue 事件值 (数字类型)
     */
    reportEffectEvent: function(eventId, eventValue){
        function pass() {};
        exec(pass, pass, "XinstallPlugin", "reportEffectEvent", [eventId, eventValue]);
    }
};