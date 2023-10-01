import Rainbow

extension String {
    func rainbowWidth(_ width: Int, tail: String = "…") -> String {
        guard raw.count > width else { return self }

        var maxLength = width - tail.count - 1
        var segments: [Rainbow.Segment] = []
        let entry = Rainbow.extractEntry(for: self)
        for var segment in entry.segments where maxLength > 0 {
            let raw = segment.text.raw
            var text = String(raw.prefix(maxLength))
            maxLength -= text.count

            if maxLength == 0, text.last == " " {
                text.removeLast()
            }

            segment.text = text
            segments.append(segment)
        }

        let tailSegment = Rainbow.Segment(text: "…", color: segments.last?.color)
        segments.append(tailSegment)

        let prefixEntry = Rainbow.Entry(segments: segments)
        return Rainbow.generateString(for: prefixEntry)
    }
}
