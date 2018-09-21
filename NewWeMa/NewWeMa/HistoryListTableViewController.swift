//
//  HistoryListTableViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/18.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class HistoryListTableViewController: UITableViewController {

    var dataModel: DataModel!
    var lists = [HistoryList]()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()

        //  loadModel
        dataModel = DataModel()
//        dataModel.appendLists(list: HistoryList(result: "liming"))
        lists = dataModel.lists

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    func initUI(){
        title = "历史记录"
        navigationController?.navigationBar.barTintColor = UIColor.gray
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)

        let list = lists[indexPath.row]
        cell.textLabel!.text = list.result
        cell.accessoryType = .detailDisclosureButton
        return cell
    }

    func makeCell(for tableView: UITableView) -> UITableViewCell{
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            return cell
        }else{
            return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
    }

}
