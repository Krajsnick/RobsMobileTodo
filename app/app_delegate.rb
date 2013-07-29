class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    nav_controller = UINavigationController.alloc.initWithRootViewController(TodosController.alloc.initWithNibName(nil, bundle: nil))

    @window.rootViewController = nav_controller
    true
  end
end
