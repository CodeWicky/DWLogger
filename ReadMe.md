<p align="center" >
<font size="20">DWLogger</font>
</p>

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%8A%A8%E7%94%BB%E5%B1%95%E7%A4%BA.gif" width=414px height=736px alt="DWLogger" title="DWLogger">
</p>

## 描述
这是一个日志助手类，他可以帮助你在App中直接查看输出的日志，同时不影响电脑端的日志输出。

更多情况下他可以让你在未连接电脑的情况下同样可以查看输出的日志，这将会解救你的测试妹妹，发生问题他也有了一定查看问题的方式。同时他将自动备份日志至磁盘，以帮助你分析数据的时候使用，当然，他也可以自动收集崩溃日志，当测试妹妹崩溃后，你可以直接查看日志和截图而不是苦逼的去复现。他还可以帮助你为日志划分等级，以方便你分等级查看日志，同时你也可以使用搜索功能来查找特定日志。

## Description
This is a Log Helper Class which enables you read logs in your App on screen directly and doesn't affect your logs on computer.

In more cases,it helps you read logs without connecting with computer,which helps tester solve problem in more ways.It will also help developer by backing up logs to disk automatically so that you can analyze data with it.What makes you excited is it also collects crash log and backs up to disk automatically.Via this you needn't struggle to find what cause the crash.By the way you can divide logs into 5 levels so that you can shield some log to find essensial information quickly.You can also search the log you want with it.

## 功能
- 自动替换NSLog为DWLogNormal
- 在App中展示日志
- 为日志划分等级，分等级查看日志
- 自动备份日志至磁盘
- 自动收集崩溃日志并备份至磁盘，同时为崩溃前屏幕截图
- 以关键字搜索指定日志
- 即时控制是否收集日志至本地
- 日志打点功能，更快定位特征日志点

## Func
- Replacing NSLog with DWLogNormal automatically.
- Displaying logs on screen in Application.
- Dividing logs into 5 levels,and look over logs in specified level.
- Backing up log automatically.
- Collecting crash log automatically and snap it.
- Searching specified log with key word.
- Controling save log to local at real-time.
- Log Marker,help you find specific log.

## 如何使用
首先，你应该将所需文件拖入工程中，或者你也可以用Cocoapods去集成他。

	pod 'DWLogger'
	
然后在AppDelegate中配置DWLogger。

	[DWLogManager configDefaultLogger];
	
如果你还想再Debug模式下收集崩溃日志，再配置下崩溃日志收集。
	
	[DWLogManager configToCollectCrash];
	
到了这里，你已经开始使用DWLogger了，Logger会自动替换NSLog为DWLogNormal，所以你的所有日志都会被Logger接收。不仅在电脑端有日志输出，App端同样也有。

一般状态下他是这个样子：
 <p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%94%B6%E8%B5%B7%E7%8A%B6%E6%80%81.png" width=207px height=368px alt="Normal" title="Normal">

点击加号会展开菜单：
<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%B1%95%E5%BC%80.png" width=207px height=368px alt="Expand" title="Expand">
  
从右向左总共六个按钮，我依次介绍：

右数第一个：收起状态按钮
> 收起菜单至收起状态，也就是一般状态。
> 长按为日志打点功能。

右数第二个：展示日志按钮
> 图例中为不可见状态，即不展示屏幕日志。点击后为可见状态，即展示屏幕日志。

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%97%A5%E5%BF%97%E7%AD%89%E7%BA%A7.png" width=207px height=368px alt="Expand" title="Expand">

上图即是展示屏幕日志的状态，当然不会有那个等级菜单。

右数第三个：控制是否收集日志至本地按钮
> 图例中状态为收集日志至本地状态，点击后为停止收集状态。

右数第四个：响应控制按钮
> 图例中为接受响应状态，及手势等控制均由屏幕日志窗口接收。点击后为拒绝响应状态，该状态屏幕日志窗口不接收响应事件，由App端接收响应。（不展示屏幕日志状态下响应控制按钮失效且默认有App端接收响应）

右数第五个：清除当前屏幕日志
> 点击后清除当前屏幕日志（不影响备份至磁盘的日志）

右数第六个：日志等级选择
> 点击后展示等级选择菜单，选择将要查看的日志等级，勾选中的等级展示，未勾选的屏蔽。再次点击或者点击屏幕中任意非按钮位置收起等级选择菜单，屏蔽日志生效。

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%B1%8F%E8%94%BD%E6%97%A5%E5%BF%97.png" width=207px height=368px alt="Shield" title="Shield">
  
DWLogger提供了5个日志等级：
> DWLog(@"全局");
>
> DWLogNormal(@"普通");
>
> DWLogInfo(@"信息");
> 
> DWLogWarning(@"警告");
> 
> DWLogError(@"错误"); 

通过调用五个等级的API来决定日志等级。  

除了六个按钮，上方还有搜索栏，用来以关键字搜索日志。

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%90%9C%E7%B4%A2%E6%97%A5%E5%BF%97.png" width=207px height=368px alt="Search" title="Search">
  
注，此处搜索日志范围为搜索前展示范围，即搜索前仅展示全局Log及NormalLog，则搜索范围也为该范围。

## Usage
Firstly,drag it into your project or use cocoapods.

	pod 'DWLogger'
	
And config DWLogger in AppDelegate.

	[DWLogManager configDefaultLogger];

If you want collect Crash Log in Debug mode,config it.
	
	[DWLogManager configToCollectCrash];
	
Having configed above,enjoy using DWLogger,it will replace NSLog with DWLogNormal automatically,so all your logs will be collected into Logger.You will look over logs not only on computer but also your phone. 

It looks like below at ordinary times：
 <p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%94%B6%E8%B5%B7%E7%8A%B6%E6%80%81.png" width=207px height=368px alt="Normal" title="Normal">
  
Click on the Plus button will expand the menu：
<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%B1%95%E5%BC%80.png" width=207px height=368px alt="Expand" title="Expand">
  
I will introduce the function of the five buttons from right to left：

No 1. from right：Close the menu.
> Close the menu to normal state.
> Long press to make a Marker.

No 2.：Display logs.
> Picture above is invisible state.Turing into visible state after clicking the button like picture below.

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%97%A5%E5%BF%97%E7%AD%89%E7%BA%A7.png" width=207px height=368px alt="Expand" title="Expand">

This picture is visible state.Sure,ignore the checkBox.

No 3.：Save log to local.
> It's save mode in above picture,it will stop save by clicking this.

No 4.：Interaction control button.
> It's interaction enabled mode in above picture,touches will be recognized by log window.After clicking the button the log window won't recognized touches,so you can control your App.(It will force not to recognized touches when the log window is invisible.)  

No 5.：Clear logs on mobile screen.
> Clear logs on mobile screen after click it.（Have no influnce on logs back-up.）

No 6.：Choose log level.
> Show log level menu by clicking,and choose which level you prefer to,it will display the level you choose but shield the others.Click the button again or somewhere else on screen to close log level menu and the configuration will make sense then.

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%B1%8F%E8%94%BD%E6%97%A5%E5%BF%97.png" width=207px height=368px alt="Shield" title="Shield">

DWLogger provide 5 log levels：
> DWLog(@"Global");
>
> DWLogNormal(@"Normal");
>
> DWLogInfo(@"Info");
> 
> DWLogWarning(@"Warning");
> 
> DWLogError(@"Error"); 

Call different API to print different level log.  

Except six buttons,there is a searchBar above,your can search log with key word.

<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E6%90%9C%E7%B4%A2%E6%97%A5%E5%BF%97.png" width=207px height=368px alt="Search" title="Search">
  
Attention!The range of searching is the same with current displaying.In other words if you select normal level,then the search range is global logs and normal logs.

## 联系作者
你可以通过在[我的Github](https://github.com/CodeWicky/DWLogger)上给我留言或者给我发送电子邮件 codeWicky@163.com 来给我提一些建议或者指出我的bug,我将不胜感激。

如果你喜欢这个小东西，记得给我一个star吧，么么哒~ 

## Contact With Me

You may issue me on [my Github](https://github.com/CodeWicky/DWLogger) or send me a email at codeWicky@163.com to tell me some advices or the bug,I will be so appreciated.

If you like it please give me a star.
