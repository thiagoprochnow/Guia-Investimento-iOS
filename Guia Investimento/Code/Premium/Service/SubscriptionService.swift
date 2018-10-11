import Foundation
import StoreKit

class SubscriptionService: NSObject, SKProductsRequestDelegate {
    
    var productIDPrefix = Bundle.main.bundleIdentifier!
    var productID = ""
    var productsRequest = SKProductsRequest()
    var mensal = SKProduct()
    var semestral = SKProduct()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if(response.products.count > 0){
            var mensal = response.products[0] as SKProduct
            var semestral = response.products[1] as SKProduct
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
  
    func restorePurchases() {
        // TODO: Initiate restore
    }
}
