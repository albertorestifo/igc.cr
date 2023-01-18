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
    def initialzie(@io : IO)
      @file = ::IGC::File.new
    end

    # Parses the file and returns a Feature
    def parse : ::IGC::File
      @io.each_line { |line| parse_line(line) }
      @file
    end

    private def parse_line(line : String)
      case line.char_at(0)
      when 'A'
        parse_fr_id(line)
      when 'H'
        parse_header(line)
      when 'I'
        @file.fix_extensions = parse_extensions(line)
      when 'J'
        @file.k_extensions = parse_extensions(line)
      when 'C'
        if @file.task.nil?
          @file.task = Task.from_c_header(line)
        else
          @file.task.parse_c_line(line)
        end
      end
    end

    private def parse_fr_id(line : String)
      @file.flight_recorder_id = line.delete_at(0, 4)
    end

    private def parse_header(line : String)
      io = IO::Memory.new(line)

      # Skip the first 2 bytes, as they contain the H identifier and Source Code
      io.skip(2)

      # Next 3 bytes contain the short code
      io.skip(3)

      # Everything up to the colon is the subject
      subject = String.build do |str|
        while char = io.read_char
          break if char == ':'
          str << char
        end
      end

      content = io.gets_to_end

      # Save the content to the raw headers
      @file.headers[subject] = content
    end

    private def parse_known_headers(short_code : String, value : String)
      case short_code
      when "ALG"
        @file.gnss_altitude = File::GNSSAltitude.new(value)
      when "ALP"
        @file.pressure_altitude = File::PressureAltitude.new(value)
      when "CCL"
        @file.competition_class = if_known(value)
      when "CID"
        @file.competition_id = if_known(value)
      when "DTE"
        @file.date = parse_date(value)
      when "FTY"
        @file.flight_recorder_type = if_known(value)
      when "GID"
        @file.glider_id = if_known(value)
      when "GTY"
        @file.glider_type = if_known(value)
      when "PLT"
        @file.pilot = if_known(value)
      when "PRS"
        @file.pressure_sensor = if_known(value)
      when "RFW"
        @file.firmware_version = if_known(value)
      when "RHW"
        @file.hardware_version = if_known(value)
      when "TZN"
        set_timezone(value)
      end
    end

    private def parse_date(value : String) : Time
      Time.parse(value, "%d%m%y", @file.timezone)
    end

    private def set_timezone(value : String)
      offset_hours = value.to_i32
      offset_seconds = offset_hours * 60 * 60

      @file.timezone = Time::Location.fixed(offset_seconds)

      # Adjust the timezone of the date of flight, just in case the DOF was
      # already parsed and it defaults to UTC.
      return if @file.date.location == @file.timezone

      @file.date = Time.local(@file.date.year, @file.date.month, @file.date.day, location: @file.timezone)
    end

    private def parse_extensions(line : String) : Hash(String, Tuple(Int32, Int32))
      io = IO::Memory.new(line)

      # First byte is the header identifier
      io.skip(1)

      nr_extensions = io.read_string(2).to_i32
      extensions = {} of String => Tuple(Int32, Int32)

      # Parse each of the extensions
      nr_extensions.times do
        start_byte = io.read_string(2).to_i32
        end_byte = io.read_string(2).to_i32
        short_code = io.read_string(3)

        extensions[short_code] = {start_byte, end_byte}
      end

      extensions
    end

    private def if_known(value) : String?
      return nil if value == "NKN"
      value
    end
  end
end
