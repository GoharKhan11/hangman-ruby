class InvalidWordError < StandardError

    def initialize (msg="The current word is not a valid choice")
        super
    end

end