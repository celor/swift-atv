#if canImport(Network)
import Testing
@testable import SwiftATV

struct ScannerSleepProxyTests {
    @Test func preferenceMetricsDoNotMergeSeparateAppleTVs() {
        let services = [
            DiscoveredService(serviceType: .sleepProxy, name: "70-35-60-63.1 Living Room",
                              host: "192.168.1.10", port: 0, txtRecord: [:]),
            DiscoveredService(serviceType: .sleepProxy, name: "70-35-60-63.1 Bedroom",
                              host: "192.168.1.11", port: 0, txtRecord: [:]),
            DiscoveredService(serviceType: .companion, name: "Living Room",
                              host: "192.168.1.10", port: 49153, txtRecord: ["rpMRtID": "living-id"]),
            DiscoveredService(serviceType: .companion, name: "Bedroom",
                              host: "192.168.1.11", port: 49153, txtRecord: ["rpMRtID": "bedroom-id"]),
        ]
        let configs = ATVScanner.configurations(from: services)
        #expect(configs.count == 2)
        #expect(Set(configs.compactMap(\.mainIdentifier)) == ["living-id", "bedroom-id"])
        #expect(configs.allSatisfy { $0.deepSleep })
        #expect(!configs.contains { $0.matchesIdentifier("70-35-60-63.1") })
    }

    @Test func preferenceOnlyProxyRetainsSleepMetadataWithoutAnIdentifier() throws {
        let service = DiscoveredService(serviceType: .sleepProxy, name: "70-35-60-63.1 Living Room",
                                        host: "192.168.1.10", port: 0, txtRecord: [:])
        let config = try #require(ATVScanner.configurations(from: [service]).first)
        #expect(config.deepSleep)
        #expect(config.name == "Living Room")
        #expect(config.mainIdentifier == nil)
        #expect(config.allIdentifiers.isEmpty)
    }
}
#endif
