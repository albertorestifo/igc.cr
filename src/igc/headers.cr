module IGC
  class Headers
    # Raw headers, as they are written into the file
    property headers : Hash(String, Tuple(String, String)) = {} of String => Tuple(String, String)

    # GNSS altitude model
    property gnss_altitude : GNSSAltitude = GNSSAltitude::Unknown

    # Pressure altitude model
    property pressure_altitude : PressureAltitude = PressureAltitude::Unknown

    # Competion parameters
    property competition_class : String?
    property competition_id : String?

    # Date of the flight
    property date : Time = Time::UNIX_EPOCH

    # Timezone offset
    property timezone : Time::Location = Time::Location::UTC

    # Manufacturer's name, Model Number
    property flight_recorder_type : String?

    # Information on the glider
    property glider_id : String?
    property glider_type : String?

    # Name of the Pilot in Charge
    property pilot : String?

    # Hardware information
    property pressure_sensor : String?
    property firmware_version : String?
    property hardware_version : String?

    # Reads a IGC header line
    def from_igc(io : IO)
      # Skip the first byte as it contains the Source Code
      io.skip(1)

      # Next 3 bytes contain the short code
      short_code = io.read_string(3)

      # Everything up to the colon is the subject
      subject = io.gets(':')
      raise IO::EOFError if subject.nil?

      # Remove the colon
      subject = subject.chomp(':')

      # The content is the rest of the line
      content = io.read_line

      # Save the content to the raw headers
      @headers[short_code] = {subject, content}

      parse_known(short_code, content)
    end

    private def parse_known(short_code : String, value : String)
      case short_code
      when "ALG"
        @gnss_altitude = GNSSAltitude.new(value)
      when "ALP"
        @pressure_altitude = PressureAltitude.new(value)
      when "CCL"
        @competition_class = maybe?(value)
      when "CID"
        @competition_id = maybe?(value)
      when "DTE"
        @date = parse_date(value)
      when "FTY"
        @flight_recorder_type = maybe?(value)
      when "GID"
        @glider_id = maybe?(value)
      when "GTY"
        @glider_type = maybe?(value)
      when "PLT"
        @pilot = maybe?(value)
      when "PRS"
        @pressure_sensor = maybe?(value)
      when "RFW"
        @firmware_version = maybe?(value)
      when "RHW"
        @hardware_version = maybe?(value)
      when "TZN"
        @timezone = parse_timezone(value)
      end
    end

    private def parse_date(value : String) : Time
      Time.parse(value, "%d%m%y", Time::Location::UTC)
    end

    private def parse_timezone(value : String)
      offset_hours = value.to_i32
      offset_seconds = offset_hours * 60 * 60

      Time::Location.fixed(offset_seconds)
    end

    private def maybe?(value) : String?
      return nil if value == "NKN"
      value
    end
  end
end
