import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let minimumContentSize = NSSize(width: 480, height: 760)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.contentMinSize = minimumContentSize
    windowFrame.size.width = max(windowFrame.size.width, minimumContentSize.width)
    windowFrame.size.height = max(windowFrame.size.height, minimumContentSize.height)
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
