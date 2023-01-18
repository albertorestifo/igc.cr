module IGC
  class ParseError < Exception
    def initialize(msg : String, io : IO? = nil)
      return super(msg) unless io
      super("#{msg}, at byte #{io.pos}")
    end
  end
end
