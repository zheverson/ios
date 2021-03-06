import UIKit

private var imageTaskKey: Void?

extension UIImageView {
    
    func startDownload(URL: NSURL) {
        
        let session = NSURLSession.sharedSession()
        let datatask = session.dataTaskWithURL(URL) {
            data, response, error in
            guard error == nil else { return }
            guard let image = UIImage(data: data!) else {
                print(URL)
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.image = image
            }
        }
        
        setImageTask(datatask)
        datatask.resume()
    }
    
    func cancelDownload() {
        if self.getImageTask?.state == .Running {
            self.getImageTask?.cancel()
        }
    }
    
    private var getImageTask: NSURLSessionDataTask? {
        return objc_getAssociatedObject(self, &imageTaskKey) as? NSURLSessionDataTask
    }
    
    private func setImageTask(task: NSURLSessionDataTask?) {
        objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UILabel {
    var setText:String {
        get {
            return self.text!
        }
        set {
            self.text = newValue
            self.sizeToFit()
        }
    }
}


extension UIButton {
    func startDownloadImage(URL:NSURL) {
        let session = NSURLSession.sharedSession()
        let datatask = session.dataTaskWithURL(URL) {
            data, response, error in
            
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue()) {
                self.setImage(image!, forState: .Normal)
            }
        }
        
        setImageTask(datatask)
        datatask.resume()
    }
    
    func cancelDownload() {
        if self.getImageTask?.state == .Running {
            self.getImageTask?.cancel()
        }
    }
    
    private var getImageTask: NSURLSessionDataTask? {
        return objc_getAssociatedObject(self, &imageTaskKey) as? NSURLSessionDataTask
    }
    
    private func setImageTask(task: NSURLSessionDataTask?) {
        objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}