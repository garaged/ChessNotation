import Foundation
import Testing

struct PrivacySurfaceAuditTests {
    private static let forbiddenSourceMarkers = [
        "import Network",
        "import AppTrackingTransparency",
        "URLSession",
        "NWConnection",
        "NWPathMonitor",
        "ASWebAuthenticationSession",
        "Firebase",
        "Analytics",
        "AdSupport",
        "ATTrackingManager",
        "advertisingIdentifier",
        "SignInWithAppleButton",
        "AuthenticationServices"
    ]

    private static let forbiddenProjectMarkers = [
        "XCRemoteSwiftPackageReference",
        "XCSwiftPackageProductDependency",
        "CODE_SIGN_ENTITLEMENTS",
        "com.apple.developer.networking",
        "com.apple.developer.applesignin",
        "com.apple.developer.icloud",
        "com.apple.developer.healthkit",
        "com.apple.developer.location",
        "INFOPLIST_KEY_NSLocation",
        "INFOPLIST_KEY_NSCamera",
        "INFOPLIST_KEY_NSMicrophone",
        "INFOPLIST_KEY_NSPhotoLibrary",
        "INFOPLIST_KEY_NSContacts",
        "INFOPLIST_KEY_NSCalendars",
        "INFOPLIST_KEY_NSUserTrackingUsageDescription"
    ]

    @Test
    func productionSourcesRemainLocalOnly() throws {
        let root = try repositoryRoot()
        let productionRoot = root.appending(path: "ChessNotation", directoryHint: .isDirectory)
        let sourceFiles = try swiftFiles(under: productionRoot)

        var violations: [String] = []
        for file in sourceFiles {
            let source = try String(contentsOf: file, encoding: .utf8)
            for marker in Self.forbiddenSourceMarkers where source.contains(marker) {
                violations.append("\(relativePath(file, root: root)): \(marker)")
            }
        }

        #expect(
            violations.isEmpty,
            Comment(rawValue: "Unexpected remote, tracking, analytics, advertising, or account surface:\n\(violations.joined(separator: "\n"))")
        )
    }

    @Test
    func projectDeclaresNoExternalPackagesEntitlementsOrSensitivePermissions() throws {
        let root = try repositoryRoot()
        let projectFile = root.appending(path: "ChessNotation.xcodeproj/project.pbxproj")
        let project = try String(contentsOf: projectFile, encoding: .utf8)

        let violations = Self.forbiddenProjectMarkers.filter(project.contains)

        #expect(
            violations.isEmpty,
            Comment(rawValue: "Unexpected package, entitlement, or sensitive permission markers: \(violations.joined(separator: ", "))")
        )
    }

    @Test
    func applicationTargetHasNoLinkedPackageProductsOrFrameworkEntries() throws {
        let root = try repositoryRoot()
        let projectFile = root.appending(path: "ChessNotation.xcodeproj/project.pbxproj")
        let project = try String(contentsOf: projectFile, encoding: .utf8)

        #expect(project.contains("packageProductDependencies = (\n\t\t\t);"))
        #expect(project.contains("3536BE732F9CF2AF00F413D1 /* Frameworks */"))
        #expect(!project.contains("PBXBuildFile section"))
    }

    private func repositoryRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let fileManager = FileManager.default

        while candidate.path != "/" {
            let project = candidate.appending(path: "ChessNotation.xcodeproj", directoryHint: .isDirectory)
            if fileManager.fileExists(atPath: project.path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }

        throw AuditError.repositoryRootNotFound
    }

    private func swiftFiles(under root: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw AuditError.sourceEnumerationFailed
        }

        return enumerator.compactMap { element in
            guard let url = element as? URL, url.pathExtension == "swift" else { return nil }
            return url
        }
    }

    private func relativePath(_ url: URL, root: URL) -> String {
        url.path.replacingOccurrences(of: root.path + "/", with: "")
    }

    private enum AuditError: Error {
        case repositoryRootNotFound
        case sourceEnumerationFailed
    }
}
