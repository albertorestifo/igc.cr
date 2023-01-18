module IGC
  class File
    enum GNSSAltitude
      Ellipsoid
      Geoid
      Unknown
      NotRecorded

      def self.new(value : String)
        case value
        when "ELL"
          Ellipsoid
        when "GEO"
          Geoid
        when "NKN"
          Unknown
        when "NIL"
          NotRecorded
        else
          raise ParseError.new("Invalid GNSS Altitude: #{value}")
        end
      end
    end

    enum PressureAltitude
      ISA # ICAO ISA
      MSL # Above Mean Sea Level
      Unknown
      NotRecorded

      def self.new(value : String)
        case value
        when "ISA"
          ISA
        when "MSL"
          MSL
        when "NKN"
          Unknown
        when "NIL"
          NotRecorded
        else
          raise ParseError.new("Invalid Pressure Altitude: #{value}")
        end
      end
    end

    # Identifier of the flight recorder
    property flight_recorder_id : String?

    # Raw headers, the key is the long-form header name, the value is the value as-is
    property headers : Hash(String, String) = {} of String => String

    # GNSS Altitude model
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
  end
end
