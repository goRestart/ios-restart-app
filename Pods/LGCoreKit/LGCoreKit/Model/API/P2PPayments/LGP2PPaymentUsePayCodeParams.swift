import Foundation

struct LGP2PPaymentUsePayCodeParams {
    let payCode: String

    var apiParams: [String : Any] {
        let attributes = ["used": true]
        return ["type": "paycode",
                "id": payCode,
                "attributes": attributes]
    }
}
