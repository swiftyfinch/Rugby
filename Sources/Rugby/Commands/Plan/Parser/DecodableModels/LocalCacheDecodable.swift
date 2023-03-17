//
//  LocalCacheDecodable.swift
//  
//
//  Created by mlch911 on 2023/3/15.
//

import Foundation

struct LocalCacheDecodable: Decodable {
	let save: LocalCacheSaveDecodable?
	let fetch: LocalCacheFetchDecodable?
	let clean: LocalCacheCleanDecodable?
}

struct LocalCacheSaveDecodable: Decodable {
	let options: LocalCacheOptionsDecodable
	let flags: FlagsDecodable?
}

struct LocalCacheFetchDecodable: Decodable {
	let options: LocalCacheOptionsDecodable
	let flags: FlagsDecodable?
	let buildOptions: CacheDecodable
}

struct LocalCacheCleanDecodable: Decodable {
	let options: LocalCacheOptionsDecodable
	let flags: FlagsDecodable?
	let all: Bool?
}

struct LocalCacheOptionsDecodable: Decodable {
	let location: String?
	let precheck: Bool?
	let useContentChecksums: Bool?
	
	let projectName: String?
	let mainProjectLocation: String?
	
	let sizeLimit: String?
	let dateLimit: String?
}

struct FlagsDecodable: Decodable {
	let bell: Bool?
	let hideMetrics: Bool?
	@BoolableIntDecodable var verbose: Int?
	let quiet: Bool?
	let nonInteractive: Bool?
}

extension LocalCache {
	static func command(from decodable: LocalCacheDecodable) throws -> Command {
		if let save = decodable.save {
			return LocalCache.LocalCacheSave(from: save)
		} else if let fetch = decodable.fetch {
			return LocalCache.LocalCacheFetch(from: fetch)
		} else if let clean = decodable.clean {
			return LocalCache.LocalCacheClean(from: clean)
		}
		throw LocalCachePlanError.noSubCommand
	}
}

extension LocalCache.LocalCacheSave {
	init(from decodable: LocalCacheSaveDecodable) {
		self.options = .init(from: decodable.options)
		self.flags = .init(from: decodable.flags)
	}
}

extension LocalCache.LocalCacheFetch {
	init(from decodable: LocalCacheFetchDecodable) {
		self.options = .init(from: decodable.options)
		self.flags = .init(from: decodable.flags)
		self.buildOptions = .init(from: decodable.buildOptions)
	}
}

extension LocalCache.LocalCacheClean {
	init(from decodable: LocalCacheCleanDecodable) {
		self.options = .init(from: decodable.options)
		self.flags = .init(from: decodable.flags)
		self.all = decodable.all ?? false
	}
}

extension LocalCache.Options {
	init(from decodable: LocalCacheOptionsDecodable) {
		self.location = decodable.location ?? "~/.rugby_cache/"
		self.precheck = decodable.precheck ?? false
		self.useContentChecksums = decodable.useContentChecksums ?? false
		self.projectName = decodable.projectName
		self.mainProjectLocation = decodable.mainProjectLocation
		self.sizeLimit = decodable.sizeLimit
		self.dateLimit = decodable.dateLimit
	}
}

extension CommonFlags {
	init(from decodable: FlagsDecodable?) {
		self.bell = decodable?.bell ?? true
		self.hideMetrics = decodable?.hideMetrics ?? false
		self.verbose = decodable?.verbose ?? 0
		self.quiet = decodable?.quiet ?? false
		self.nonInteractive = decodable?.nonInteractive ?? false
	}
}

enum LocalCachePlanError: Error {
	case noSubCommand
}
