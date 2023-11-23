import ArgumentParser
import RugbyFoundation

extension AsyncParsableCommand {
    var dependencies: Vault { Vault.shared }
    static var dependencies: Vault { Vault.shared }
    static var settings: Settings { Vault.shared.settings }
}
