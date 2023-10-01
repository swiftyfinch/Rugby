extension String {
    var quoted: String {
        #""\#(self)""#
    }
}
