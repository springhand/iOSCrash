//
//  SYO_Crash2.swift
//  Niugentou
//
//  Created by huzc on 2017/12/20.
//  Copyright © 2017年 com.huixiang zhitong.cn. All rights reserved.
//

import UIKit

// Crash处理总入口，请留意不要集成多个crash捕获，NSSetUncaughtExceptionHandler可能会被覆盖. NSException的crash也会同时生成一个signal异常信息。
func crashHandle() {
    // 注册signal，捕获相关crash
    registerCrashSignal()
    // 注册NSException，捕获相关crash
    NSSetUncaughtExceptionHandler(set_UncaughtEH)
}

func set_UncaughtEH(exception: NSException) {
    let arr = exception.callStackSymbols// 得到当前调用栈信息
    let reason = exception.reason       // 非常重要，就是崩溃的原因
    let name = exception.name           // 异常类型
    
    let dataStr = "crash-exception type:\(name) \n crash reason:\(String(describing: reason)) \n call stack info: \(arr)"
    SYO_Crash2.saveCrash(crashString: dataStr)
}

// 注册信号
func registerCrashSignal() {
    signal(SIGABRT, signalHandle)
    signal(SIGSEGV, signalHandle)
    signal(SIGBUS, signalHandle)
    signal(SIGTRAP, signalHandle)
    signal(SIGILL, signalHandle)
    
    signal(SIGHUP, signalHandle)
    signal(SIGINT, signalHandle)
    signal(SIGQUIT, signalHandle)
    signal(SIGFPE, signalHandle)
    signal(SIGPIPE, signalHandle)
}

// 取消注册新号
func unRegisterCrashSignal() {
    signal(SIGINT, SIG_DFL)
    //.....
}

// 触发信号后操作
func signalHandle(signal: Int32) -> Void {
    var string = String()
    string += "Stack:\n"
    // 增加偏移量地址
    string = string.appendingFormat("slideAdress:0x%0x\r\n", calculate())
    // 增加错误信息
    for symbol in Thread.callStackSymbols {
        string = string.appendingFormat("%@\r\n", symbol)
    }
    SYO_Crash2.saveCrash(crashString: string)
    exit(signal)
}

class SYO_Crash2: NSObject {
    fileprivate static let CrashFold: String = "CrashFold"
    fileprivate static let crashTxt: String = "crashTxt.txt"
    fileprivate static var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last! 
    fileprivate static let fileManager = FileManager.default
    
    class func saveCrash(crashString: String) {
        let filePath = SYO_Crash2.crearCrashFold()
        try? crashString.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    // 获取当前时间
    fileprivate class func get_NowDate() -> String {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: nowDate)
        return dateString
    }
    
    // 创建文件夹
    fileprivate class func crearCrashFold() -> String {
        let filePath = (path as NSString).appendingPathComponent(CrashFold)
        print("filePath = \(filePath)")
        if fileManager.fileExists(atPath: filePath) != true {
            do {    
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("error = \(error)")
            }
        }
        return (filePath as NSString).appendingPathComponent(crashTxt)
    }
    
    // 返回崩溃日子 data字符串
    class func returnCrashFold(callBack: (_ dataString: String) -> ()){
        var filePath = (path as NSString).appendingPathComponent(CrashFold)
        filePath = (filePath as NSString).appendingPathComponent(crashTxt)
        print("filePath = \(filePath)")
        if self.fileManager.fileExists(atPath: filePath) == true {
            let data = self.fileManager.contents(atPath: filePath)!
            let dataString = String.init(data: data, encoding: String.Encoding.utf8)
            print("dataString = \(dataString)")
            callBack(dataString!)
        } else {
            callBack("")
        }
    }
    
    // 上传后删除
    class func deleteCrashFold() {
        var filePath = (path as NSString).appendingPathComponent(CrashFold)
        filePath = (filePath as NSString).appendingPathComponent(crashTxt)
        try? self.fileManager.removeItem(atPath: filePath)
    }
}
