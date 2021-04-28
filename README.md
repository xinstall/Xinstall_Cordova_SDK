# cordova-plugin-xinstall

> Xinstall 为了方便Cordova开发同学接入SDK的封装SDK

## 前期准备

1. 在Xinstall官网注册自己的账号
2. 创建应用，获得需要使用的appKey 和 scheme

【注】scheme 只有android 使用到，iOS使用的是universal link

## 安装插件

执行下列命令安装并配置`xinstall`插件

```
cordova plugin add cordova-plugin-xinstall --variable XINSTALL_APPKEY={AppKey} --variable XINSTALL_SCHEME={Scheme}
```

## 客户端配置

### 1. Android

Android 不需要任何配置

### 2. iOS

在xxx-Info.plist 文件中需要添加

```xml
<key>com.xinstall.APP_KEY</key>
<string>{appKey}</string>
```

## 调用API

### 1.快速下载

如果只需要快速下载功能，无需其它功能（携带参数安装、渠道统计、一键拉起），完成初始化即可(这里指安装插件)

### 2. 一键拉起

#### 拉起参数获取

调用以下代码注册拉起回调，应尽早调用。如在 `deviceready` 事件回调之时注册

```js
window.xinstall.registerWakeUpHandler(function(data) {
       // 对data进行处理
}, function(msg){
       console.log("xinstall.wakeup error : " + msg)
});
```

**iOS 由于使用Universal Link 技术**

首先，我们需要到[苹果开发者网站](https://developer.apple.com/)，为当前的 App ID 开启关联域名 (Associated Domains) 服务：

![](res/1.png)

为刚才开发关联域名功能的 App ID 创建新的（或更新现有的）描述文件，下载并导入到Xcode中(通过xcode自动生成的描述文件，可跳过这一步)：

![](res/2.png)

在Xcode中配置Xinstall为当前应用生成的关联域名 (Associated Domains) ：**applinks:xxxx.xinstall.top**

![](res/3.png)

### 3. 携带参数安装

```js
window.xinstall.getInstallParams(function(data) {
        //对安装data进行处理
}, function(msg){
        console.log('xinstall.getInstall error: ' + msg);
}, 15);
```

【注】过期时间只有androidSDK 提供，后期肯能会去除。

成功回调的data数据为

```json
{"channelCode":"渠道号","timeSpan":"获取数据间隔时间","data":{"uo":"{\"testkey\":\"1111\"}","co":""}}
// uo 为页面参事
// co 为点击参数
```

### 4. 渠道统计相关

#### 4.1 注册量统计

```js
window.xinstall.reportRegister();
```

#### 4.2 渠道效果统计

```js
window.xinstall.reportEffectEvent(eventId, eventVal);
```

【注】事件需要在Xinstall 后台添加

## 导出apk/ipa包并上传

参考官网文档

[iOS集成-导出ipa包并上传](https://doc.xinstall.com/integrationGuide/iOSIntegrationGuide.html#四、导出ipa包并上传)

[Android-集成](https://doc.xinstall.com/integrationGuide/AndroidIntegrationGuide.html#四、导出apk包并上传)

## 如何测试功能

参考官方文档 [测试集成效果](https://doc.xinstall.com/integrationGuide/comfirm.html)

## 更多 Xinstall 进阶功能

若您想要自定义下载页面，或者查看数据报表等进阶功能，请移步 [Xinstall 官网](https://xinstall.com) 查看对应文档。

若您在集成过程中如有任何疑问或者困难，可以随时[联系 Xinstall 官方客服](https://wpa1.qq.com/qsw1OZaM?_type=wpa&qidian=true) 在线解决。