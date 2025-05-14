1.错误：
Could not build the precompiled application for the device.
Error (Xcode): 2 duplicate symbols

Error (Xcode): Linker command failed with exit code 1 (use -v to see invocation)

Error launching application on XXXXXX’s iPhone.
解决：
1. Fixed: Add "-ld64" under Build Setting -> Other Linker Flags

   2.pod install --repo-update 

2.错误：   
 2.1:zolozkit_for_flutter (from `.symlinks/plugins/zolozkit_for_flutter/ios`) was resolved to 1.5.3.250415134605, which depends on
      zolozkit (= 1.5.3.250415134605)
None of your spec sources contain a spec satisfying the dependency: `zolozkit (= 1.5.3.250415134605)`.

2.2:Unable to find a specification for `OrderedSet (~> 6.0.3)` depended     upon by `flutter_inappwebview_ios`

解决：
source 'https://github.com/zoloz-pte-ltd/zoloz-demo-ios'
source 'https://github.com/CocoaPods/Specs.git'
target 'Runner' do 上面加上上两行

然后:
pod install --repo-update




3.布局底部按钮被软键盘顶上解决：
Scaffold(
      resizeToAvoidBottomInset: false, Scaffold这里为false
      
Column(
    children: [
            Flexible(
                child: Column(
                  children: [输入框等控件集合],
                    )
            ),
            Button(),
    ]
)
    //判断是否注册了控制器
 if (Get.isRegistered<AccountCenterController>()) {
        final acontroller = Get.find<AccountCenterController>();
        acontroller.configData();
      }



4.这个属性的效果是 body 部分的背景图片会扩展到 AppBar 后面，从而实现一个完整的背景覆盖效果。如果你希望 AppBar 的背景颜色透明，并且 body 的内容能够显示在 AppBar 后面，那么这个属性是非常有用的。
Scaffold(
     extendBodyBehindAppBar: true,
);

5.头部可滑动有最大高和最小高 悬浮部分高度,而且有list可以下拉刷新 上拉加载更多等操作 
    解决：NestedScrollView headerSliverBuilder:设置SliverPersistentHeader 的delegate头部视图
                          body:TabBarView里面嵌套SmartRefresher 再嵌套ListView


环境配置:
export PATH="$PATH:/Users/luke/Documents/flutter/bin"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn 
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH=/Users/luke/Documents/flutter/bing\cache\dart-sdk\nbin:$PATH

source ~/.bash_profile

Sourcetree忽略设置： 设置->Git->全局忽略列表-》编辑文件



插件:
ADB Tools
adb_idea
Bloc
Dart
Flutter
Flutter Bloc
Flutter Enhancement Suite 代码增强提示
Flutter Intl
Flutter Snippets
Flutter-img-sync
Flutter_add_image
FlutterAssetsGenerator
FlutterJsonBeanFactory
FlutterX
GetX
JsonToDart
Proxy AI
Rainbow Brackets 彩虹括号，Dart的括号太多了，让括号有颜色，还是很有作用的
Trae AI
Translation
WidgetGenerator 自动生成Widget接口



One Dark Theme
GoogleTranslation



1.Stack - 堆叠布局-可以容纳多个组件，以叠加的方式摆放子组件，后者居上。拥有Alignment属性，可以与Positioned组件联合使用，精准并有效摆放。同Android端FramLayout布局相似。

2.Positioned - 一般只用于 Stack 组件中 可以控制  Stack 子组件位置的组件

Unicorn_Max

3.Align  - 精准控制子组件的位置
4.Row -为水平布局，可以使其包含的子控件按照水平方向排列
5.Column -为垂直布局，可以使其包含的子控件按照垂直方向排列
10.Expanded 只能在Column，Row，Flex以及它们的子组件    •    Expanded作用是，填充剩余空间或比例
7.Container - 容器组件包含一个子 Widget，自身具备如 alignment、padding 等基础属性，方便布局过程中摆放 child。可以对子widget进行 绘制(painting)、定位(positioning)、调整大小(sizing)操作。

8.Opacity -透明度
9.AspectRatio 调整子元素宽高比
10.InkWell  添加点击事件 Ink设置背景包裹InkWell InkResponse设置高亮
11.GestureDetector 手势事件 事件种类比上面的多
12.ListView 可滑动列表 类似tabbarView
13.Padding 边距组件
14.Divider 线条
15.VoidCallback 回调 通常用于事件监听器 不带参数
16.ValueChanged 回调 接受一个参数
17.BoxDecoration 1.color 颜色 设置背景颜色 Colors.red
                2.border 边框
                3.borderRadius 圆角
                4.boxShadow 阴影
                5.gradient 渐变
                6.image 图片
18.FractionallySizedBox 可控制组件在水平/垂直方向上填充满父容器
19 .Flexible  帮助Row、Column、Flex的子控件充满父控件，它的用法很灵活，也具有权重的属性。跟Flexible相类似的控件还有Expanded。
Spacer控件。Spacer() 相当于弹簧的效果,使两个控件之间的距离达到最大值. (在页面不可滑动时才有效果)
Flexible和 Expanded的区别是：
Flexible是一个控制Row、Column、Flex等子组件如何布局的组件。 Flexible组件可以使Row、Column、Flex等子组件在主轴方向有填充可用空间的能力(例如，Row在水平方向，Column在垂直方向)，但是它与Expanded组件不同，它不强制子组件填充可用空间。 Flexible组件必须是Row、Column、Flex等组件的后裔，并且从Flexible到它封装的Row、Column、Flex的路径必须只包括StatelessWidgets或StatefulWidgets组件(不能是其他类型的组件，像RenderObjectWidgets)。 Row、Column、Flex会被Expanded撑开，充满主轴可用空间。

20.RichText TextSpan 富文本
21.CupertinoSegmentedControl 分段控制

22.Offstage是Flutter中的一个布局小部件，它通过offstage属性来控制其子组件是否出现在屏幕上。当offstage设置为true时，子组件将被隐藏，同时它也不会占用布局空间；当设置为false时，子组件将正常显示。

Swiper 轮播图swiper
ClipRRect(. 圆角
            borderRadius: BorderRadius.circular(8),
          )
ClipOval
MediaQuery MediaQuery.removeViewPadding移除内间距
SingleChildScrollView
Wrap 流式布局 比如搜索历史

在flutter开发中，使用ListView时出现一种现象：初始加载数据时，偏离顶部一定距离或者说顶部没有对齐，设置ListView属性padding为0即可
  children: [
    ...items, // 使用点点点操作符来展开列表
  ],

AutomaticKeepAliveClientMixin 常驻内存 切换不会重新加载 主要用于pageview

FractionallySizedBox 组件 : 可控制组件在水平/垂直方向上填充满父容器

 Material( //可以实现阴影
      elevation: 5,
      shadowColor: Colors.grey[100],

ExpansionTitle带动画的展开列表组件

NestedScrollView可以嵌套其它可滚动widget的widget NestedScrollView+ListView+SliverAppBar
BackdropFilter 高斯模糊

SingleTickerProviderStateMixin 单个动画

TickerProviderStateMixin 多个动画

 LayoutBuilder 通过 LayoutBuilder，我们可以在布局过程中拿到父组件传递的约束信息，然后我们可以根据约束信息动态的构建不同的布局。
SafeArea 适配全面屏组件
Opacity 控制透明度组件
AbsorbPointer 事件拦截
用MediaQuery.removePadding()
GetBuilder 自动刷新  例子 购物车页面发生变化 用这个每次进入页面都刷新 
spread(…list素组)运算符 展开数组 三个点 展开运算符
List数组.asMap().entries.map(entries(包含key value)) //key是下标

类()..方法名()(或者属性)  可以利用..语法 级联运算符

//每次进入页面都更新
GetBuilder<CartController>(
    initState: (state) {

//当前设备
TargetPlatform.android


先从内存获取,再磁盘,再网络,一般会用到lru算法。LinkedHashMap LRU
///详细日志
logger.t(“Trace log");
///调试信息
logger.d("Debug log");
///普通信息
logger.i("Info log");
///警告信息
logger.w("Warning log");
///错误信息
logger.f(“Fatal log");

persistent_bottom_nav_bar 5.0.2
smooth_page_indicator 1.1.0  页面page

flutter 创建package
在Flutter中创建一个包（package），通常是指创建一个可以被其他Dart或Flutter项目使用的库。以下是创建Flutter包的步骤：
*         打开终端（命令行）。 
*         使用mkdir命令创建一个新目录用于存放你的包。 
*         进入该目录。 
*         运行flutter create --template=package your_package_name命令来创建一个新的包。 
例如：


启动页 iOS 750X1334. 1026X2636 1242X2688
    Android 720X1280 960X1600 1440X2560


mkdir my_package
cd my_package
flutter create --template=package my_package
这将会创建一个名为my_package的目录，并在其中生成一个可以发布到pub.dev的包架构。
创建完包后，你可以在其中添加你的代码，并通过编写单元测试来保证代码质量。最后，通过pub publish命令将你的包发布到pub.dev上，供全世界的开发者使用。

get create page productContent

get create view:thirdPage on productContent

get generate model on models from "https://miapp.itying.com/api/pcontent?id=59f6a2d27ac40b223cfdcf81"

// fund是目录下
get create page:featured on fund  

//kyc_base_info是要创建的页面  mine是文件夹 kyc是文件夹 mine/kyc文件目录下
get create page:kyc_base_info on mine/kyc










---------------------插件--------------------------------
cbor 二进制对象编码/解码
flutter_easyloading HUD
 
Riverpod  状态管理 比较好用
auto_size_text 自适应字体大小文本
app_installer 打开应用商店和安装 APK iOS 评分
onesignal_flutter 消息推送
  forui: ^0.9.0 底部tabbar
  forui_assets: ^0.9.0
  forui_hooks: ^0.9.0
--------------------------------
GetxService:
区别：

GetView 是 GetX 中的一个便捷小部件，用于创建只需要一个 Controller 的页面。通常情况下，我们需要手动获取 Controller 实例，但使用 GetView 可以自动获取指定的 Controller，无需在代码中显式调用 Get.find。

GetWidget 是 GetX 提供的一个便捷工具，主要用于创建具有持久化控制器实例的组件或小部件。与 GetView 相似，GetWidget 可以直接获取 Controller，但它的特殊之处在于：在多次构建过程中，GetWidget 会一直保持同一个控制器实例，而不会因为小部件重新构建而丢失状态。

        GetWidget的特点如下：

持久化：无论小部件如何重新构建，控制器实例都不会丢失。
便于封装：非常适合封装那些需要频繁构建的组件，避免重新获取控制器。
泛型支持：通过泛型指定控制器的类型，使得代码安全、简洁
        它的使用场景如下：

用于需要重复构建的组件，例如列表项、按钮等。

当组件需要依赖控制器的数据且不希望控制器实例被重新创建时（例如，在不同页面的 Tab 中共享状态）。

GetxController：

GetxController 用于管理特定页面或 widget 的状态。每个页面或 widget 可以拥有一个或多个 GetxController，用于管理其自身的状态和逻辑。
GetxController 是短暂存在的，通常与页面或 widget 的生命周期相关联。它们在页面或 widget 销毁时被销毁。
GetxService：

GetxService 用于全局状态管理和持久化服务。它们在整个应用程序生命周期中是单例存在的，并且负责处理应用程序范围内的状态和服务。
GetxService 通常用于管理全局性的业务逻辑、持久化数据、全局状态等，它们不会随着页面或 widget 的销毁而销毁。
使用场景：
GetxController 的使用场景：

管理特定页面或 widget 的状态和逻辑。
处理特定页面或 widget 的用户交互和数据更新。
GetxService 的使用场景：

管理全局性的业务逻辑、全局状态和持久化数据。
处理应用程序级别的服务，例如用户登录状态、数据缓存、全局设置等。
总结：
在实际开发中，GetxController 通常用于管理特定页面或 widget 的状态，而 GetxService 则用于处理应用程序范围内的全局状态和服务。合理使用它们可以让开发人员更清晰地组织和管理应用程序的状态和逻辑，提高代码的可维护性和复用性。
————————————————


