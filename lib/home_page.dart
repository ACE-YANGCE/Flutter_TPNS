import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app07/list_data.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

List listData = [
  ListData(0, "关于账号接口"),
  ListData(1, "设置账号"),
  ListData(1, "解绑账号"),
  ListData(1, "清除全部账号"),
  ListData(0, "关于标签接口"),
  ListData(1, "绑定一个标签"),
  ListData(1, "解绑一个标签"),
  ListData(1, "更新标签"),
  ListData(1, "清除全部标签"),
  ListData(0, "关于应用接口"),
  ListData(1, "注册推送服务"),
  ListData(1, "注销推送服务"),
  ListData(1, "设备推送标识"),
  ListData(1, "上报当前角标数"),
  ListData(1, "SDK 版本")
];
String inputStr = "ACE_Flutter";
int clickIndex = 0;

class _HomePageState extends State<HomePage> {
  static const methodChannel =
      const MethodChannel('com.ace.plugin.flutter_app/tpns_notification');

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('TPNS Demo')),
        body: ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, item) => _itemList(listData[item], item)));
  }

  _itemList(ListData _listData, index) {
    return GestureDetector(
        child: Container(
            height: 50.0,
            color: _listData.status == 0
                ? Colors.blue.withOpacity(0.8)
                : Colors.transparent,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_listData.name,
                          style: TextStyle(
                              color: _listData.status == 0
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: _listData.status == 0 ? 16.0 : 15.0))
                    ]))),
        onTap: () {
          if (_listData.status == 1) {
            clickIndex = index;
            _requestTPNSAPI(_listData, index);
          }
        });
  }

  _showDialog(title, content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  FlatButton(
                      child: Text("确定"),
                      onPressed: () => Navigator.pop(context))
                ]));
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    /// 开启DEBUG
    XgFlutterPlugin().setEnableDebug(true);

    /// 添加回调事件
    XgFlutterPlugin().addEventHandler(
      onRegisteredDeviceToken: (String msg) async {
        print("HomePage -> onRegisteredDeviceToken -> $msg");
      },
      onRegisteredDone: (String msg) async {
        print("HomePage -> onRegisteredDone -> $msg");
        _showDialog('注册成功', msg);
      },
      unRegistered: (String msg) async {
        print("HomePage -> unRegistered -> $msg");
        // _showAlert(msg);
      },
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
        print("HomePage -> onReceiveNotificationResponse -> $msg");
        _showDialog('通知类消息接收', msg.toString());
      },
      onReceiveMessage: (Map<String, dynamic> msg) async {
        print("HomePage -> onReceiveMessage -> $msg");
        _showDialog('透传类消息接收', msg.toString());
        await methodChannel
            .invokeMethod('tpns_extras', msg['customMessage'])
            .then((val) {
          print("HomePage -> 透传类消息接收 -> $val");
          if (val != null) {
            _showDialog('透传类消息点击', val);
          }
        });
      },
      xgPushDidSetBadge: (String msg) async {
        print("HomePage -> xgPushDidSetBadge -> $msg");

        /// 在此可设置应用角标
        /// XgFlutterPlugin().setAppBadge(0);
      },
      xgPushDidBindWithIdentifier: (String msg) async {
        print("HomePage -> xgPushDidBindWithIdentifier -> $msg");
        _showDialog('绑定标签 $inputStr', msg);
      },
      xgPushDidUnbindWithIdentifier: (String msg) async {
        print("HomePage -> xgPushDidUnbindWithIdentifier -> $msg");
        _showDialog('解绑账号', msg);
      },
      xgPushDidUpdatedBindedIdentifier: (String msg) async {
        print("HomePage -> xgPushDidUpdatedBindedIdentifier -> $msg");
        switch (clickIndex) {
          case 1:
            _showDialog('设置账号', msg);
            break;
          case 6:
            _showDialog('解绑标签 $inputStr', msg);
            break;
          case 7:
            _showDialog('更新标签 $inputStr', msg);
            break;
        }
      },
      xgPushDidClearAllIdentifiers: (String msg) async {
        print("HomePage -> xgPushDidClearAllIdentifiers -> $msg");
        switch (clickIndex) {
          case 3:
            _showDialog('清除全部账号', msg);
            break;
          case 8:
            _showDialog('清除全部账号', msg);
            break;
        }
      },
      xgPushClickAction: (Map<String, dynamic> msg) async {
        print("HomePage -> xgPushClickAction -> $msg");
        _showDialog('通知类消息点击', msg.toString());
      },
    );

    /// 如果您的应用非广州集群则需要在startXG之前调用此函数
    /// 香港：tpns.hk.tencent.com
    /// 新加坡：tpns.sgp.tencent.com
    /// 上海：tpns.sh.tencent.com
    // XgFlutterPlugin().configureClusterDomainName("tpns.hk.tencent.com");

    /// 启动TPNS服务
    // XgFlutterPlugin().startXg("1500018481", "AW8Y2K3KXZ38");
  }

  _requestTPNSAPI(ListData _listData, index) {
    switch (index) {
      case 1:
        XgFlutterPlugin().setAccount(inputStr, AccountType.UNKNOWN);
        break;
      case 2:
        XgFlutterPlugin().deleteAccount(inputStr, AccountType.UNKNOWN);
        break;
      case 3:
        XgFlutterPlugin().cleanAccounts();
        break;

      case 5:
        XgFlutterPlugin().addTags([inputStr]);
        break;
      case 6:
        XgFlutterPlugin().deleteTags([inputStr]);
        break;
      case 7:
        XgFlutterPlugin().setTags([inputStr]);
        break;
      case 8:
        XgFlutterPlugin().cleanTags();
        break;

      case 10:
        XgFlutterPlugin().startXg("1500018481", "AW8Y2K3KXZ38");
        break;
      case 11:
        getTPNSToken(_listData.name);
        break;
      case 12:
        XgFlutterPlugin().stopXg();
        break;
      case 13:
        XgFlutterPlugin().setBadge(int.parse("10"));
        break;
      case 14:
        getTPNSSDKVersion(_listData.name);
        break;
    }
  }

  Future<void> getTPNSToken(title) async {
    try {
      String xgToken = await XgFlutterPlugin.xgToken;
      print('HomePage -> getTPNSToken -> $xgToken');
      _showDialog(title, xgToken);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getTPNSSDKVersion(title) async {
    try {
      String sdkVersion = await XgFlutterPlugin.xgSdkVersion;
      print('HomePage -> getTPNSSDKVersion -> $sdkVersion');
      _showDialog(title, sdkVersion);
    } catch (e) {
      print(e.toString());
    }
  }
}
