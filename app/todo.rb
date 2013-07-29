class Todo
  URL = "http://localhost:3000/"

  def self.get_json
    uri = NSURL.URLWithString("#{URL}todos.json") 

    # Simulate latency
    # sleep 2
    data = NSData.dataWithContentsOfURL(uri)
    puts "Data retrieved"

    error_ptr = Pointer.new(:object)
    json_data = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingMutableContainers,
                                                       error:error_ptr)

    json_data

  end

  def self.post_json(todo_text)
    uri = NSURL.URLWithString("#{URL}todos")
    request = NSMutableURLRequest.requestWithURL(uri,
                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy,
                                                 timeoutInterval: 60.0)
    error_ptr = Pointer.new(:object)
    data = NSJSONSerialization.dataWithJSONObject(todo_text, options: 0, error: error_ptr)

    request.setHTTPMethod("POST")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(data.length.to_s, forHTTPHeaderField: "Content-Length")
    request.setHTTPBody(data)


    responseHeader = Pointer.new(:object)
    # get back raw data
    response = NSURLConnection.sendSynchronousRequest(request, returningResponse: responseHeader, error: error_ptr)
    # decode the data and return json hash object
    NSJSONSerialization.JSONObjectWithData(response, options:NSJSONReadingMutableContainers, error: error_ptr)
  end

end
