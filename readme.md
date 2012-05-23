# AutoResponse - Linux下的http调试小工具

## 原理
建立一个代理服务器，将浏览器的代理设为此代理服务器提供的地址（默认为127.0.0.1:9000），可以根据规则返回指定的内容。

## 用法

* 下载并运行

        git clone git://github.com/qhwa/autoresponse.git
        bundle
        bin/ar

* 第一次运行后会自动在 `$HOME` 下生成一个 `.autoresponse` 目录，里面含有一个 rules 文件，这个文件就是规则配置文件。你可以根据自己的需要进行修改。
* 为你的浏览器配置代理服务器为 `http://127.0.0.1:9000`
    例如配置一条规则为：

        url 'http://i.me'
        send 'Hello world!'

* 访问网址 `http://i.me`，将会看到"Hello world!"

## 特色功能
* 支持Ruby语法，返回动态内容
* 支持正则表达式匹配

## TODO:
* GUI的http调试页面, 将处理过的请求显示出来
* GUI的设置界面(考虑基于http服务实现，在浏览器中操作)
* 跨平台地监控配置文件的变化（目前只支持Linux）
