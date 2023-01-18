# Parser for IGC files
module IGC
  class Parser
    # Creates a new parser from a string
    def self.new(str : String)
      new IO::Memory.new(str)
    end

    # Creates a new parser from a buffer
    def self.new(slice : Bytes)
      new IO::Memory.new(slice)
    end

    # Created a new parser from any IO, like a file
    def initialize(@io : IO)
      @file = ::IGC::File.new
      @eof = false

      @b_extensions = {} of String => Tuple(Int32, Int32)
      @k_extensions = {} of String => Tuple(Int32, Int32)
    end

    # Parses the file and returns a Feature
    def parse : ::IGC::File
      until @eof
        parse_line
      end
      @file
    end

    private def parse_line
      # Debugging:
      # puts "PARSING LINE #{String.new(@io.peek.not_nil!, "UTF-8", :skip).split("\n").first}"

      case @io.gets(1)
      when "A"
        @file.flight_recorder_id = @io.read_line
      when "H"
        @file.headers.from_igc(@io)
      when "I"
        @b_extensions = parse_extensions
      when "J"
        @k_extensions = parse_extensions
      when "C"
        @file.task = Task.from_igc(@io)
      when nil
        @eof = true
      else
        # Skip line
        @io.gets
      end
    end

    private def parse_extensions : Hash(String, Tuple(Int32, Int32))
      nr_extensions = @io.read_string(2).to_i32
      extensions = {} of String => Tuple(Int32, Int32)

      # Parse each of the extensions
      nr_extensions.times do
        start_byte = @io.read_string(2).to_i32
        end_byte = @io.read_string(2).to_i32
        short_code = @io.read_string(3)

        extensions[short_code] = {start_byte, end_byte}
      end

      # Complete the line
      @io.gets

      extensions
    end

    private def if_known(value) : String?
      return nil if value == "NKN"
      value
    end
  end
end
