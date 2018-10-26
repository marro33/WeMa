//
//  HistoryListTableViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/18.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class HistoryListTableViewController: UITableViewController, UINavigationControllerDelegate {

    var dataModel: DataModel!
    var item: HistoryList!


    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        loadHistoryListItems()

    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    func loadHistoryListItems(){
        dataModel = DataModel()
        //        lists = dataModel.lists
    }


    func initUI(){
        title = "历史记录"
        navigationController?.navigationBar.barTintColor = UIColor.gray
    }



    // MARK: - IBFunction

    @IBAction func cancel(){
        navigationController?.popViewController(animated: true)
    }


        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showResult"{
//                let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
//                let vc = mainStoryboard.instantiateViewController(withIdentifier: "1111") as! HistoryDetailViewController

                let vc = segue.destination as! HistoryDetailViewController
                print(item.result)
                vc.result = item.result
            }

//            self.navigationController?.pushViewController(vc, animated: true)
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            item = dataModel.lists[indexPath.row]
            performSegue(withIdentifier: "showResult", sender: nil)
        }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        item = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //        lists.remove(at: indexPath.row)
        dataModel.delete(indexOfitem: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModel.lists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let item = dataModel.lists[indexPath.row]
        cell.textLabel!.text = item.result + "  " + item.time
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
