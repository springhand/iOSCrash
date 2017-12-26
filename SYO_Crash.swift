//
//  SYO_Crash.swift
//  Niugentou
//
//  Created by huzc on 2017/12/20.
//  Copyright © 2017年 com.huixiang zhitong.cn. All rights reserved.
//

import UIKit

class SYO_Crash: NSObject {
    
    fileprivate static let CrashFold: String = "CrashFold"
    fileprivate static let crashTxt: String = "crashTxt.txt"
    fileprivate static var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
    fileprivate static let fileManager = FileManager.default
    
    class func set_UncaughtEH() ->@convention(c)(NSException) -> Void {
        return { (exception) -> Void in
            let arr = exception.callStackSymbols// 得到当前调用栈信息
            let reason = exception.reason       // 非常重要，就是崩溃的原因
            let name = exception.name           // 异常类型
            
            print("crash type:\(name) \n crash reason:\(reason) \n call stack info: \(arr)")
            let dataStr = "crash-exception type:\(name) \n crash reason:\(String(describing: reason)) \n call stack info: \(arr)"
            let data = dataStr.data(using: String.Encoding.utf8)
            let filePath = SYO_Crash.crearCrashFold()
            try? data!.write( to: URL(fileURLWithPath: filePath), options: [.atomic])            
        }
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
