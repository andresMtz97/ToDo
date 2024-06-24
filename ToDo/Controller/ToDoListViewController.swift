//
//  ToDoListViewController.swift
//  ToDo
//
//  Created by Rafael González on 20/04/24.
//

import UIKit

class ToDoListViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var ToDoList: UITableView!
    
    var currentTask: TDTask?
    var taskManager: TasksManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ToDoList.delegate = self
        ToDoList.dataSource = self
        taskManager = TasksManager(context: context)
        taskManager?.fetch()
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        if ToDoList.isEditing {
            ToDoList.setEditing(false, animated: true)
            sender.title = "Edit"
            addTaskButton.isEnabled = true
        } else {
            ToDoList.setEditing(true, animated: true)
            sender.title = "Done"
            addTaskButton.isEnabled = false
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskSegue" {
            let destination = segue.destination as! TaskDetailViewController
            destination.detailTask = taskManager?.getTask(at: ToDoList.indexPathForSelectedRow!.row)
        }
    }

}


extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskManager?.countTasks() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TDTaskCell
        cell.title.text = taskManager?.getTask(at: indexPath.row).title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTaskSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentTask = taskManager?.getTask(at: indexPath.row)
            self.context.delete(currentTask!)
            
            do {
                try self.context.save()
            } catch let error {
                print("Error: ", error)
            }
            taskManager?.fetch()
            ToDoList.reloadData()
        }
    }
    
    @IBAction func unwindToDoList(segue: UIStoryboardSegue) {
        print("Unwind Segue")
        let source = segue.source as! TaskDetailViewController
        currentTask = source.detailTask
        
        do {
            try context.save()
        } catch let error {
            print("error: ", error)
        }
        
        taskManager?.fetch()
        ToDoList.reloadData()
    }
    
    
}

