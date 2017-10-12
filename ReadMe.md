<p align="center" >
<font size="20">DWLogger</font>
</p>

<!--<p align="center" >
  <img src="https://github.com/CodeWicky/DWLogger/raw/master/%E5%8A%A8%E7%94%BB%E5%B1%95%E7%A4%BA.gif" alt="DWLogger" title="DWLogger">
</p>-->

## 描述
这是一个日志助手类，他可以帮助你在App中直接查看输出的日志，同时不影响电脑端的日志输出。

更多情况下他可以让你在未连接电脑的情况下同样可以查看输出的日志，这将会解救你的测试妹妹，发生问题他也有了一定查看问题的方式。同时他将自动备份日志至磁盘，以帮助你分析数据的时候使用，当然，他也可以自动收集崩溃日志，当测试妹妹崩溃后，你可以直接查看日志而不是苦逼的去复现。他还可以帮助你为日志划分等级，以方便你分等级查看日志，同时你也可以使用搜索功能来查找特定日志。

## Description
This is a Log Helper Class which enables you read logs in your App on screen directly and doesn't affect your logs on computer.

In more cases,it helps you read logs without connecting with computer,which helps tester solve problem in more ways.It will also help developer by backing up logs to disk automatically so that you can analyze data with it.What makes you excited is it also collects crash log and backs up to disk automatically.Via this you needn't struggle to find what cause the crash.By the way you can divide logs into 5 levels so that you can shield some log to find essensial information quickly.You can also search the log you want with it.

## 功能
- 自动替换NSLog为DWLogNormal
- 在App中展示日志
- 为日志划分等级，分等级查看日志
- 自动备份日志至磁盘
- 自动收集崩溃日志并备份至磁盘
- 以关键字搜索指定日志

## Func
- Replacing NSLog with DWLogNormal automatically.
- Displaying logs on screen in Application.
- Dividing logs into 5 levels,and look over logs in specified level.
- Backing up log automatically.
- Collecting crash log automatically.
- Searching specified log with key word.

## 如何使用
首先，你应该将所需文件拖入工程中，或者你也可以用Cocoapods去集成他。

	pod 'DWLogger'
	
然后在AppDelegate中配置DWLogger。

	[DWLogManager configDefaultLogger];
	
如果你还想再Debug模式下收集崩溃日志，再配置下崩溃日志收集。
	
	[DWLogManager configToCollectCrash];
	
到了这里，你已经开始使用DWLogger了，Logger会自动替换NSLog为DWLogNormal，所以你的所有日志都会被Logger接收。不仅在电脑端有日志输出，App端同样也有。

一般状态下他是这个样子：


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
