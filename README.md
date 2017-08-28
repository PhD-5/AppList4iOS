# 获取iOS设备中所有的应用列表

本想写个launchd，不断刷新回传，感觉太频繁，后来改为了Hook了SpringBoard，手机重启或者Respring时会触发应用列表刷新操作

## 方法一：通过plist获取
读取`/var/mobile/Library/MobileInstallation/LastLaunchServicesMap.plist`

## 方法而：通过私有函数
`LSApplicationWorkspace`中的`allInstalledApplications`

## Socket回传
目前回传的ip和port是读取了 **PreferenceLoad**中的数据，也可以自己修改为硬编码
