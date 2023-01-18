require "string_scanner"
require "./igc/**"

# TODO: Write documentation for `Igc`
module IGC
  VERSION = "0.1.0"

  def self.parse(io) : IGC::File
    IGC::Parser.new(io).parse
  end
end
