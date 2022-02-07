# cordova-plugin-xinstall

> Xinstall 为了方便Cordova开发同学接入SDK的封装SDK

> 【重要说明】：从 v1.5.0 版本（含）开始，调用 Xinstall 模块的任意方法前，必须先调用一次初始化方法（init 或者 initWithAd），否则将导致其他方法无法正常调用。
>
> 从 v1.5.0 以下升级到 v1.5.0 以上版本后，需要自行修改代码调用初始化方法，Xinstall 模块无法在升级后自动兼容。

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

### 1. 快速下载

如果只需要快速下载功能，无需其它功能（携带参数安装、渠道统计、一键拉起），完成初始化即可(这里指安装插件)

### 2.初始化SDK

```js
window.xinstall.init();
```

### 3. 一键拉起

#### 拉起参数获取

调用以下代码注册拉起回调，应尽早调用。如在 `deviceready` 事件回调之时注册

```js
// 第一种回调方法 只有是wakeup 操作才会回调------------
window.xinstall.registerWakeUpHandler(function(data) {
       // 对data进行处理
}, function(msg){
       console.log("xinstall.wakeup error : " + msg)
});
// -----------------------------------------------

// 第二种回调方法， 只要调用方法，就一定有回调------------
 window.xinstall.registerWakeUpDetailHandler(function(data) {
       // 对data进行处理
},function(msg) {
        console.log("xinstall.registerWakeUpDetailHandler : " + msg)
});
//-----------------------------------------------------
```

【注】：两种回调方法选择一个使用。

两种回调返回的data格式分别为：

```json
// 第一种回调的json 数据
{
    "channelCode":"渠道编号",  // 字符串类型。渠道编号，没有渠道编号时为 ""
    "data":{									// 对象类型。唤起时携带的参数。
        "co":{								// co 为唤醒页面中通过 Xinstall Web SDK 中的点击按钮传递的数据，key & value 均可自定义，key & value 数量不限制
            "自定义key1":"自定义value1", 
            "自定义key2":"自定义value2"
        },
        "uo":{   							// uo 为唤醒页面 URL 中 ? 后面携带的标准 GET 参数，key & value 均可自定义，key & value 数量不限制
            "自定义key1":"自定义value1",
            "自定义key2":"自定义value2"
        }
    }
}

// 第二种回调的json 数据
{
  "wakeUpData":
  {
    "channelCode":"渠道编号",  // 字符串类型。渠道编号，没有渠道编号时为 ""
    "data":{									// 对象类型。唤起时携带的参数。
        "co":{								// co 为唤醒页面中通过 Xinstall Web SDK 中的点击按钮传递的数据，key & value 均可自定义，key & value 数量不限制
            "自定义key1":"自定义value1", 
            "自定义key2":"自定义value2"
        },
        "uo":{   							// uo 为唤醒页面 URL 中 ? 后面携带的标准 GET 参数，key & value 均可自定义，key & value 数量不限制
            "自定义key1":"自定义value1",
            "自定义key2":"自定义value2"
        }
    }
  },
  "error": 
  {
    "errorType" : 7,					// 数字类型。代表错误的类型，具体数字对应类型可在下方查看
    "errorMsg" : "xxxxx"			// 字符串类型。错误的描述
  }
}


/** errorType 对照表：
 * iOS
 * -1 : SDK 配置错误；
 * 0 : 未知错误；
 * 1 : 网络错误；
 * 2 : 没有获取到数据；
 * 3 : 该 App 已被 Xinstall 后台封禁；
 * 4 : 该操作不被允许（一般代表调用的方法没有开通权限）；
 * 5 : 入参不正确；
 * 6 : SDK 初始化未成功完成；
 * 7 : 没有通过 Xinstall Web SDK 集成的页面拉起；
 *
 * Android
 * 1006 : 未执行init 方法;
 * 1007 : 未传入Activity，Activity 未比传参数
 * 1008 : 用户未知操作 不处理
 * 1009 : 不是唤醒执行的调用方法
 * 1010 : 前后两次调起时间小于1s，请求过于频繁
 * 1011 : 获取调起参数失败
 * 1012 : 重复获取调起参数
 * 1013 : 本次调起并非为XInstall的调起
 * 1004 : 无权限
 * 1014 : SCHEME URL 为空
 */
```



**iOS 由于使用Universal Link 技术**

首先，我们需要到[苹果开发者网站](https://developer.apple.com/)，为当前的 App ID 开启关联域名 (Associated Domains) 服务：

![](res/1.png)

为刚才开发关联域名功能的 App ID 创建新的（或更新现有的）描述文件，下载并导入到Xcode中(通过xcode自动生成的描述文件，可跳过这一步)：

![](res/2.png)

在Xcode中配置Xinstall为当前应用生成的关联域名 (Associated Domains) ：**applinks:xxxx.xinstall.top** 和 **applinks:xxxx.xinstall.net**

> 具体的关联域名可在 Xinstall管理后台 - 对应的应用控制台 - iOS下载配置 页面中找到

![](https://doc.xinstall.com/Cordova/res/3.png)

### 4. 携带参数安装

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
{"channelCode":"渠道号","timeSpan":"获取数据间隔时间","data":{"uo":"{\"testkey\":\"1111\"}","co":""},"isFirstFetch":true}
// uo 为页面参事
// co 为点击参数
// isFirstFetch 是否第一次获取安装参数
```

### 5. 事件统计相关

#### 5.1 注册量统计

```js
window.xinstall.reportRegister();
```

#### 5.2 事件统计

```js
window.xinstall.reportEffectEvent(eventId, eventVal);
```

**补充说明**

只有 Xinstall 后台创建事件统计，并且代码中 **传递的事件ID** 与 **后台创建的ID** 一致时，上报数据才会被统计。

#### 5.3 事件明细统计

> 除了旧有事件业务，我们还开发了事件明细统计，用来统计各个事件具体发生情况。
>
> 1.5.7 及以后版本可用

在使用之前要现在后台管理系统中打开该事件明细统计功能，具体如下：

![](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/event.png)

在开启权限之后，我们直接使用Xinstall SDK 的`reportEventWhenOpenDetailInfo`方法上传单个事件的第二个详细值

```js
window.xinstall.reportEventWhenOpenDetailInfo(eventId, eventVal,eventSubValue);
```

最终在事件列表中可以点击查看查阅具体详情的内容

![](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/event_detail_list.png)





### 6. 广告平台渠道功能

> 如果您在 Xinstall 管理后台对应 App 中，**只使用「自建渠道」，而不使用「广告平台渠道」，则无需进行本小节中额外的集成工作**，也能正常使用 Xinstall 提供的其他功能。
>
> 注意：根据目前已有的各大主流广告平台的统计方式，目前 iOS 端和 Android 端均需要用户授权并获取一些设备关键值后才能正常进行 [ 广告平台渠道 ] 的统计，如 IDFA / OAID / GAID 等，对该行为敏感的 App 请慎重使用该功能。

#### 6.1 配置工作

**iOS 端：**

在 Xcode 中打开 iOS 端的工程，在 `Info.plist` 文件中配置一个权限作用声明（如果不配置将导致 App 启动后马上闪退）：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>这里是针对获取 IDFA 的作用描述，请根据实际情况填写</string>
```

在 Xcode 中，找到 App 对应的「Target」，再点击「General」，然后在「Frameworks, Libraries, and Embedded Content」中，添加如下两个框架：

* AppTrackingTransparency.framework
* AdSupport.framework

**Android 端：**

  相关接入可以参考广告平台联调指南中的[《Android集成指南》](https://doc.xinstall.com/AD/AndroidGuide.html)

1. 接入IMEI需要额外的全下申请，需要在`AndroidManifest`中添加权限声明

   ```java
   <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
   ```

2. 如果使用OAID，因为内部使用反射获取oaid 参数，所以都需要外部用户接入OAID SDK 。具体接入参考[《Android集成指南》](https://doc.xinstall.com/AD/AndroidGuide.html)



##### 6.2、更换初始化方法

**使用新的 initWithAd 方法，替代原先的 init 方法来进行模块的初始化**

> iOS 端使用该方法时，需要传入 IDFA（在 JS 脚本内）。您可以使用任意方式在 JS 脚本中获取到 IDFA，例如第三方获取 IDFA 的模块。
>

**入参说明**：需要主动传入参数，字典

入参内部字段：

* iOS 端：

  <table>
         <tr>
             <th>参数名</th>
             <th>参数类型</th>
             <th>描述 </th>
         </tr>
         <tr>
             <th>idfa</th>
             <th>字符串</th>
             <th>iOS 系统中的广告标识符</th>
         </tr>
    			<tr>
             <th>asaEnable</th>
             <th>boolean</th>
             <th>是否开启 ASA 渠道，不需要时可以不传。详见《8. 苹果搜索广告（ASA）渠道功能》</th>
         </tr>
     </table>


* Android 端：

  <table>
            <tr>
                <th>参数名</th>
                <th>参数类型</th>
                <th>描述 </th>
            </tr>
            <tr>
                <th>adEnabled</th>
                <th>boolean</th>
                <th>是否使用广告功能</th>
            </tr>
    				<tr>
                <th>oaid （可选）</th>
                <th>string</th>
                <th>OAID</th>
            </tr>
    				<tr>
                <th>gaid（可选）</th>
                <th>string</th>
                <th>GaID(google Ad ID)</th>
            </tr>
        </table>

**调用示例**

```javascript

  // oaid和gaid 为选传，不传则代表使用SDK自动去获取（SDK内不包括OAID SDK，需要自己接入）
  window.xinstall.initWithAd({adEnabled:true,idfa:"idfa需要自己传入",oaid:"oaid测试",gaid:"测试",asaEnable:true});
  // 如果希望在完成初始化，立即执行之后的步骤可以通过 下列代码实现-------------------------
  //window.xinstall.initWithAd({adEnable:true,idfa:"外部获取的idfa",asaEnable:true},function() {
	//		window.xinstall.getInstallParams 或者 window.xinstall.registerWakeUpHandler 等操作
	//});
  //-----------------------------------------------------------------------------

```

##### 7.3、上架须知

**在使用了广告平台渠道后，若您的 App 需要上架，请认真阅读本段内容。**

##### 7.3.1 iOS 端：上架 App Store

1. 如果您的 App 没有接入苹果广告（即在 App 中显示苹果投放的广告），那么在提交审核时，在广告标识符中，请按照下图勾选：

![IDFA](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_7.png)



1. 在 App Store Connect 对应 App —「App隐私」—「数据类型」选项中，需要选择：**“是，我们会从此 App 中收集数据”**：

![AppStore_IDFA_1](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_1.png)

在下一步中，勾选「设备 ID」并点击【发布】按钮：

![AppStore_IDFA_2](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_2.png)

点击【设置设备 ID】按钮后，在弹出的弹框中，根据实际情况进行勾选：

- 如果您仅仅是接入了 Xinstall 广告平台而使用了 IDFA，那么只需要勾选：**第三方广告**
- 如果您在接入 Xinstall 广告平台之外，还自行使用 IDFA 进行别的用途，那么在勾选 **第三方广告** 后，还需要您根据您的实际使用情况，进行其他选项的勾选

![AppStore_IDFA_3](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_3.png)

![AppStore_IDFA_4](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_4.png)

勾选完成后点击【下一步】按钮，在 **“从此 App 中收集的设备 ID 是否与用户身份关联？”** 选项中，请根据如下情况进行选择：

- 如果您仅仅是接入了 Xinstall 广告平台而使用了 IDFA，那么选择 **“否，从此 App 中收集的设备 ID 未与用户身份关联”**
- 如果您在接入 Xinstall 广告平台之外，还自行使用 IDFA 进行别的用途，那么请根据您的实际情况选择对应的选项

![AppStore_IDFA_5](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_5.png)

最后，在弹出的弹框中，选择 **“是，我们会将设备 ID 用于追踪目的”**，并点击【发布】按钮：

![AppStore_IDFA_6](https://cdn.xinstall.com/iOS_SDK%E7%B4%A0%E6%9D%90/IDFA_6.png)

##### 7.3.2 Android 端

无特殊需要注意，如碰上相关合规问题，参考 [《应用合规指南》](https://doc.xinstall.com/应用合规指南.html)

### 8. 苹果搜索广告（ASA）渠道功能

>  如果您在 Xinstall 管理后台对应 App 中，**不使用「ASA渠道」，则无需进行本小节中额外的集成工作**，也能正常使用 Xinstall 提供的其他功能。

#### 8.1 更换初始化方法

**使用新的 initWithAd 方法，替代原先的 init 方法来进行模块的初始化**

## **initWithAd**

**入参说明**：需要主动传入参数，JSON对象

入参内部字段：

* iOS 端：

  <table>
         <tr>
             <th>参数名</th>
             <th>参数类型</th>
             <th>描述 </th>
         </tr>
         <tr>
             <th>idfa</th>
             <th>string</th>
             <th>iOS 系统中的广告标识符（不需要时可以不传）</th>
         </tr>
         <tr>
             <th>asaEnable</th>
             <th>boolean</th>
             <th>是否开启 ASA 渠道，true 时为开启，false 或者不传时均为不开启</th>
         </tr>
     </table>

**回调说明**：无需传入回调函数

**调用示例**

```javascript
// idfa 为广告传入参数，如果未使用到，可以不传入
window.xinstall.initWithAd({asaEnable:true},function() {
       // 初始化回调 为选传参数
       window.xinstall.getInstallParams(function(data){
                
       }, 10);
 });
 
```

**可用性**

iOS系统

可提供的 1.5.5 及更高版本





## 导出apk/ipa包并上传

参考官网文档

[iOS集成-导出ipa包并上传](https://doc.xinstall.com/integrationGuide/iOSIntegrationGuide.html#四、导出ipa包并上传)

[Android-集成](https://doc.xinstall.com/integrationGuide/AndroidIntegrationGuide.html#四、导出apk包并上传)

## 如何测试功能

参考官方文档 [测试集成效果](https://doc.xinstall.com/integrationGuide/comfirm.html)

## 更多 Xinstall 进阶功能

若您想要自定义下载页面，或者查看数据报表等进阶功能，请移步 [Xinstall 官网](https://xinstall.com) 查看对应文档。

若您在集成过程中如有任何疑问或者困难，可以随时[联系 Xinstall 官方客服](https://wpa1.qq.com/qsw1OZaM?_type=wpa&qidian=true) 在线解决。