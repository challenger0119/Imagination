//
//  Hitokoto.swift
//  Imagination
//
//  Created by YouJuny on 2020/5/5.
//  Copyright © 2020 Star. All rights reserved.
//

import Foundation

class Hitokoto {
    static let keyForHitokoto = "keyForHitokoto"
    static let hitokotoOn = "keyForHitokotoOnOff"
    
    static var off: Bool {
        get { UserDefaults.standard.bool(forKey: hitokotoOn) }
        set { UserDefaults.standard.set(newValue, forKey: hitokotoOn) }
    }

     static var hitokotoBody: String? {
        get {
            return UserDefaults.standard.string(forKey: keyForHitokoto)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: keyForHitokoto)
            } else {
                UserDefaults.standard.removeObject(forKey: keyForHitokoto)
            }
        }
    }

    class func getNewHitokotoBody() {
        let hitokotoAPI = "https://v1.hitokoto.cn?encode=text"
        if let url = URL(string: hitokotoAPI) {
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data, let hitokoto = String(data: data, encoding: .utf8) {
                    Dlog("hitokoto \(hitokoto)")
                    self.hitokotoBody = hitokoto
                }
            }.resume()
        }
    }
    
    class func needShowTime() -> TimeInterval {
        if let hitokoto = hitokotoBody {
            return TimeInterval(hitokoto.count / 10 + 3)
        } else {
            return 0
        }
    }
}
