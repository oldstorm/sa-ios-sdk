import CryptoSwift

extension Data {
    var md5: Data {
        return Data(CryptoSwift.MD5().calculate(for: self.bytes))
    }
}

