import Foundation
import StoreKit

class SubscriptionService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var productIDPrefix = Bundle.main.bundleIdentifier!
    var productID = ""
    var productsRequest = SKProductsRequest()
    var mensal = SKProduct()
    var semestral = SKProduct()
    var isPremium = false
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if(response.products.count > 0){
            mensal = response.products[0] as SKProduct
            semestral = response.products[1] as SKProduct
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale.init(identifier: "pt_BR")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Subscription Error: " + error.localizedDescription)
    }
  
    func fetchAvailableProducts() {
        let mensal = "mensal"
        let semestral = "semestral"
    
        let identifier = Set([mensal,semestral])
        
        let productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
  
    func purchaseProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier //also show loader
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        receiptValidation()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Error: " + error.localizedDescription)
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
        print("Error: " + transaction.error!.localizedDescription)
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func receiptValidation() {
        let SUBSCRIPTION_SECRET = "34ed2f6ff7d1498eac992c2406ecdde6"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        self.isPremium = false
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)

            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options:[])
                            let receiptDictionary = appReceiptJSON as? [String: Any]
                            let receipt = receiptDictionary!["receipt"] as? [String: Any]
                            let inApps = receipt!["in_app"] as? [Any]
                            var foundPremium = false
                            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                            inApps?.forEach{ inApp in
                                let subscription = inApp as! NSDictionary
                                let expires = Int(subscription["expires_date_ms"] as! String)
                                if(expires! > timestamp){
                                    foundPremium = true
                                }
                            }
                            // Sets isPremium variable to true to enable premium contents
                            if(foundPremium){
                                self.isPremium = true
                            } else {
                                self.isPremium = false
                            }
                            print("Premium: " + String(self.isPremium))
                            //print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                            // if you are using your server this will be a json representation of whatever your server provided
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                            self.isPremium = true
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                        self.isPremium = true
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
                self.isPremium = true
            }
        }
    }
}
