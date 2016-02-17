import UIKit

private var imageTaskKey: Void?

extension UIImageView {
    
    func startDownload(URL: NSURL) {
        
        let session = NSURLSession.sharedSession()
        let datatask = session.dataTaskWithURL(URL) {
            data, response, error in
            
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue()) {
                
                self.image = image!
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
