class Todo
  SERVER_URL = "http://localhost:3000/"

  def self.get_json

    url = NSURL.URLWithString("#{SERVER_URL}todos.json") 

    # Simulate latency
    # sleep 2
    data = NSData.dataWithContentsOfURL(url)
    unless data
      return [{text: "Server is unreachable", done: false, error: true}]
    end
    puts "Data retrieved"

    error_ptr = Pointer.new(:object)
    json_data = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingMutableContainers,
                                                       error:error_ptr)

    json_data

  end

  def self.post_json(post_data, method = "POST")

    uri = case method
          when "POST"
            "todos"
          when "DELETE"
            "todos/#{post_data}"
          when "PATCH"
            "todos/#{post_data[:id]}"
          end

    url = NSURL.URLWithString("#{SERVER_URL + uri}")
    request = NSMutableURLRequest.requestWithURL(url,
                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy,
                                                 timeoutInterval: 60.0)
    request.setHTTPMethod(method)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    error_ptr = Pointer.new(:object)
    unless method == "DELETE"
      data = NSJSONSerialization.dataWithJSONObject(post_data, options: 0, error: error_ptr)
      request.setValue(data.length.to_s, forHTTPHeaderField: "Content-Length")
      request.setHTTPBody(data)
    end


    responseHeader = Pointer.new(:object)
    # get back raw data
    response = NSURLConnection.sendSynchronousRequest(request, returningResponse: responseHeader, error: error_ptr)
    # decode the data and return json hash object
    NSJSONSerialization.JSONObjectWithData(response, options:NSJSONReadingMutableContainers, error: error_ptr)
  end

end
