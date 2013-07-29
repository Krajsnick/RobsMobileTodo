class TodosController < UIViewController
  def viewDidLoad
    super

    self.title = "Todos"

    toolbar = UIToolbar.alloc.initWithFrame([[0, 1], [100, 44]])
    add_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                                   target: self,
                                                                   action: 'show_text_input')
    add_button.style = UIBarButtonItemStyleBordered
    # toolbar.setItems([self.editButtonItem, add_button])
    refresh_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                       target:self,
                                                                       action:'refresh_data')
    self.navigationItem.leftBarButtonItem = refresh_button
    self.navigationItem.setRightBarButtonItems([add_button, self.editButtonItem], animated: false)

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.dataSource = self
    @table.delegate = self
    self.view.addSubview @table
    @todos = Todo.get_json
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @cell_id ||= "CELL_ID"

    cell = tableView.dequeueReusableCellWithIdentifier(@cell_id) || begin
    UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@cell_id) 
    end

    cell.textLabel.text = @todos[indexPath.row][:text]

    cell
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    cell.backgroundColor = UIColor.greenColor if @todos[indexPath.row][:done]
  end

  # def numberOfSectionsInTableView(tableView)
  # 1
  # end

  def tableView(tableView, numberOfRowsInSection: section)
    @todos.count 
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    todo_alert = UIAlertView.alloc.init
    todo_alert.message = @todos[indexPath.row][:text]
    todo_alert.addButtonWithTitle "OK"
    todo_alert.show
  end

  def setEditing(editing, animated: animated)
    super
    @table.setEditing(editing, animated: true)
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete
      puts "Deleting from backend"
      @todos.delete_at(indexPath.row)
      @table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade)
    end
  end

  def refresh_data
    @todos = Todo.get_json
    @table.reloadData
  end

  def show_text_input
    # create only one instance of @text_input
    unless @text_input
      @text_input = UIAlertView.alloc.initWithTitle("Todo:", message: nil, delegate: self,
                                                    cancelButtonTitle: "Cancel", otherButtonTitles: nil)
      @text_input.alertViewStyle = UIAlertViewStylePlainTextInput
      @text_input.textFieldAtIndex(0).delegate = self
    end
    @text_input.textFieldAtIndex(0).text = ""
    @text_input.show
  end

  def add_todo
    @table.beginUpdates
    @todos.unshift({text: @text_input.textFieldAtIndex(0).text, done: false})
    indexPath = NSIndexPath.indexPathForRow(0, inSection: 0)
    @table.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade)
    @table.endUpdates
  end

  def textFieldShouldReturn(textField)
    # If user tries to enter an empty t0do
    unless textField.text.empty?
      add_todo 
      @text_input.dismissWithClickedButtonIndex(0, animated: true)
      true
    else
      false
    end
    # @text_input.dismissWithClickedButtonIndex(@text_input.firstOtherButtonIndex, animated: true)
  end

end
