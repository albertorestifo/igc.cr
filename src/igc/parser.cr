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
      when "G"
        signature = @file.security_signature || ""
        signature + @io.read_line
        @file.security_signature = signature
      when "B"
        @file.fixes << parse_fix
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

      # Ensure the extensions are sorted by start byte

      # Complete the line
      @io.gets

      extensions
    end

    private def parse_fix
      hours = @io.read_string(2).to_i32
      minutes = @io.read_string(2).to_i32
      seconds = @io.read_string(2).to_i32

      date = @file.headers.date
      time = Time.utc(date.year, date.month, date.day, hours, minutes, seconds)

      coords = LatLon.from_igc(@io)
      valid = @io.read_string(1) == "A"

      pressure_altitude = @io.read_string(5).to_i32
      gnss_altitude = @io.read_string(5).to_i32

      fix = Fix.new(coords: coords, time: time, valid: valid, pressure_altitude: pressure_altitude, gnss_altitude: gnss_altitude)

      extensions = @io.read_line
      return fix if @b_extensions.empty?

      # We have already read a bunch of bytes, which we need to subtract from the start and end bytes
      diff = 36

      @b_extensions.each do |key, position|
        start_byte = position[0] - diff
        end_byte = position[1] - diff
        fix.extensions[key] = extensions[start_byte..end_byte]
      end

      fix.populate_known_extensions

      # Adjust time with TDS if present
      if fix.extensions.has_key?("TDS")
        decimal_seconds = fix.extensions["TDS"].to_i32
        nanoseconds = decimal_seconds * 10_000_000
        fix.time = Time.utc(time.year, time.month, time.day, time.hour, time.minute, time.second, nanosecond: nanoseconds)
      end

      fix
    end

    private def if_known(value) : String?
      return nil if value == "NKN"
      value
    end
  end
end
