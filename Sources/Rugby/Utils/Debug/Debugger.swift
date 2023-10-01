import Foundation

final class Debugger {
    // https://stackoverflow.com/a/33177600/6197314
    func isAttached() -> Bool {
        // Buffer for "sysctl(...)" call's result.
        var info = kinfo_proc()
        // Counts buffer's size in bytes (like C/C++'s `sizeof`).
        var size = MemoryLayout.stride(ofValue: info)
        // Tells we want info about own process.
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        // Call the API (and assert success).
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        // Finally, checks if debugger's flag is present yet.
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
