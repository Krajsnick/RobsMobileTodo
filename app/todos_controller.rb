class TodosController < UIViewController
  def viewDidLoad
    super

    self.title = "Todos"

    self.navigationController.navigationBar.tintColor = "#2ba6cb".to_color

    add_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                                   target: self,
                                                                   action: 'show_text_input')
    add_button.style = UIBarButtonItemStyleBordered
    refresh_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                       target:self,
                                                                       action:'refresh_data')
    self.navigationItem.leftBarButtonItem = refresh_button
    self.navigationItem.setRightBarButtonItems([add_button, self.editButtonItem], animated: false)

    @table = setup_table_view
    self.view.addSubview @table
    setup_gesture_rec
    @todos = Todo.get_json
  end

  def setup_table_view
    table = UITableView.alloc.initWithFrame(self.view.bounds)
    table.dataSource = self
    table.delegate = self
    table.separatorStyle = UITableViewCellSeparatorStyleNone
    table
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
    cell.textLabel.textColor = UIColor.whiteColor
    cell.backgroundColor = UIColor.clearColor
    cell.backgroundView = UIImageView.alloc.initWithFrame([[0, 0], [320, 44]])
    if @todos[indexPath.row][:done]
      cell.backgroundView.image = UIImage.imageNamed("done_bg.png")
    else
      cell.backgroundView.image = UIImage.imageNamed("cell_bg.png")
    end
  end

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
      todo = @todos[indexPath.row][:id]
      Todo.post_json(todo, "DELETE")
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
    todo_data = {text: @text_input.textFieldAtIndex(0).text, done: false}
    todo = Todo.post_json(todo_data)
    @table.beginUpdates
    @todos.unshift(todo)
    indexPath = NSIndexPath.indexPathForRow(0, inSection: 0)
    @table.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade)
    @table.endUpdates
  end

  def toggle_done(gesture)
    if gesture.state == UIGestureRecognizerStateBegan
      point = gesture.locationInView(@table)
      indexPath = @table.indexPathForRowAtPoint(point)
      todo = @todos[indexPath.row]
      todo[:done] = todo[:done] == false ? true : false # toggle true/false
      # Only send what's needed to server
      json_data = todo.select { |k,v| k == "id" || k == "done" }
      Todo.post_json(json_data, "PATCH")
      @table.reloadData
    end
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
  end

  def setup_gesture_rec
    gesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action: 'toggle_done:')
    @table.addGestureRecognizer(gesture)
  end

end
