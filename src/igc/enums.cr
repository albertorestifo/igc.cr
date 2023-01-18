module IGC
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
end
