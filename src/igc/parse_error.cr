module IGC
  class ParseError < Exception
    def initialize(msg : String, io : IO)
      super("#{msg}, at byte #{io.pos}")
    end
  end
end
