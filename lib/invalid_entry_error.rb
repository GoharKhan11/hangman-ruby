class InvalidEntryError < StandardError

    def initialize (msg="The current entry is not valid")
        super
    end

end