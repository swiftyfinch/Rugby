//
//  RugbyProgressBar+OutputCollection.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//

extension RugbyProgressBar {
    func output<T: Collection>(_ collection: T, text: String, deletion: Bool = false) where T.Element == String {
        update(info: "\(text) ".yellow + "(\(collection.count))" + ":".yellow)
        collection.caseInsensitiveSorted().forEach {
            let bullet = deletion ? "* ".red : "* ".yellow
            update(info: bullet + "\($0)")
        }
    }
}
