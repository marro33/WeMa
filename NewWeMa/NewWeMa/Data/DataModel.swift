//
//  DataModel.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/19.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import Foundation

class DataModel{

    var lists = [HistoryList]()

    init() {
        loadChecklists()
        let everLoadData = "everLoadData"
        if(!UserDefaults.standard.bool(forKey: everLoadData)){
            let date = Date()
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let time = dateFormat.string(from: date)
            self.append(list: HistoryList.init(result: "004444834349", time: time))
            UserDefaults.standard.set(true, forKey: everLoadData)
        }
//        registerDefaults()
    }

    func append(list: HistoryList){
        self.lists.append(list)
        saveChecklists()
    }

    func delete(indexOfitem: Int){
        self.lists.remove(at: indexOfitem)
        saveChecklists()
    }

    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent(
            "Checklists.plist")
    }

    func saveChecklists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array!")
        }
    }

    func loadChecklists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([HistoryList].self, from: data)
            } catch {
                print("Error decoding item array!")
            }
        }
    }

//    func registerDefaults() {
//        let dictionary: [String:Any] = [ "ChecklistIndex": -1, "FirstTime": true ]
//
//        UserDefaults.standard.register(defaults: dictionary)
//    }

//    func handleFirstTime() {
//        let userDefaults = UserDefaults.standard
//        let firstTime = userDefaults.bool(forKey: "FirstTime")
//
//        if firstTime {
//            let checklist = Checklist(name: "List")
//            lists.append(checklist)
//
//            indexOfSelectedChecklist = 0
//            userDefaults.set(false, forKey: "FirstTime")
//            userDefaults.synchronize()
//        }
//    }

//    func sortChecklists() {
//        lists.sort(by: { checklist1, checklist2 in
//            return checklist1.name.localizedStandardCompare(checklist2.name) ==
//                .orderedAscending })
//    }
}
