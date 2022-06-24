/**
 Copyright (c) 2007 Tomas Pettersson
               2016 Yohei Yoshihara
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

import Cocoa

let GeneratorSelectedNotification = Notification.Name(rawValue: "GeneratorSelectedNotification")
let MutateSelectedNotification = Notification.Name(rawValue: "MutateSelectedNotification")
let RandomizeSelectedNotification = Notification.Name(rawValue: "RandomizeSelectedNotification")
let ParameterChangedNotification = Notification.Name(rawValue: "ParameterChangedNotification")

class ViewController: NSSplitViewController {
  let audio = SFXRAudio()
  var parameterViewController: ParameterViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(ViewController.generatorSelected(notification:)),
                                           name: GeneratorSelectedNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(ViewController.mutate(notification:)),
                                           name: MutateSelectedNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(ViewController.randomize(notification:)),
                                           name: RandomizeSelectedNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(ViewController.parameterChanged(notification:)),
                                           name: ParameterChangedNotification,
                                           object: nil)
    for vc in self.children {
      if let paramVC = vc as? ParameterViewController {
        paramVC.updateUI(parameters: audio.parameters)
        self.parameterViewController = paramVC
      }
    }
    precondition(self.parameterViewController != nil)
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func generatorSelected(notification: Notification) {
    guard let generator = notification.userInfo?["generator"] as? GeneratorType else {
      return
    }
    self.audio.parameters = SFXRGenerator.generate(generator: generator)
    self.audio.play()
    updateUI()
  }
  
  @objc func mutate(notification: Notification) {
    self.audio.parameters = SFXRGenerator.mutate(params: self.audio.parameters)
    self.audio.play()
    updateUI()
  }
  
  @objc func randomize(notification: Notification) {
    self.audio.parameters = SFXRGenerator.random()
    self.audio.play()
    updateUI()
  }
  
  func updateUI() {
    self.parameterViewController.updateUI(parameters: self.audio.parameters)
    if let winCtrl = self.view.window?.windowController as? WindowController {
      winCtrl.waveTypeSegmentedControl.selectedSegment = self.audio.parameters.waveType.rawValue
    }
  }
  
  @objc func parameterChanged(notification: Notification) {
    self.parameterViewController.updateParameters(parameters: &self.audio.parameters)
    self.audio.play()
  }
  
  @IBAction func export(_ sender: Any) {
    guard let window = self.view.window else {
      return
    }
    let panel = NSSavePanel()
    panel.title = "Export .WAV"
    panel.allowedFileTypes = ["wav"]
    panel.canSelectHiddenExtension = true
    panel.beginSheetModal(for: window) { (result) in
      if result == .OK {
        if let url = panel.url {
          let data = self.audio.exportWAV()
          try! data.write(to: url)
        }
      }
    }
  }
  
  func play(_ sender: Any) {
    self.audio.play()
  }
}

