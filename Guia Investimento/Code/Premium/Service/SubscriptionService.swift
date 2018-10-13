import Foundation
import StoreKit

class SubscriptionService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var productIDPrefix = Bundle.main.bundleIdentifier!
    var productID = ""
    var productsRequest = SKProductsRequest()
    var mensal = SKProduct()
    var semestral = SKProduct()
    var isPremium = true
    
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
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}
