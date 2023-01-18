module IGC
  struct Fix
    # Location of the fix
    property coords : LatLon

    # Time at which the fix was recorded.
    # If the TDS record is present, then the decimal seconds presion will be applied.
    property time : Time

    # Is the fix valid?
    property valid : Bool

    # Pressure altitude in meters
    property pressure_altitude : Int32

    # GPS altitude in meters
    property gnss_altitude : Int32

    # Extensions contained in the fix record
    property extensions : Hash(String, String) = {} of String => String

    # Well-known extensions **might** be decoded into their respective types

    # HDM: Magnetic heading, 0 is north
    property magnetic_heading : UInt16?

    # HDT: True heading, 0 is north
    property true_heading : UInt16?

    # IAS: Airspeed in km/h
    property air_speed : Int32?

    # SIU: Number of satilles in use
    property satellites_in_use : Int32?

    # TAS: True air speed in km/h
    property true_air_speed : Int32?

    # WDI: Direction the wind is coming from, 0 is north
    property wind_direction : UInt16?

    # WSP: Wind speed in km/h
    property wind_speed : Int32?

    def initialize(@coords, @time, @valid, @pressure_altitude, @gnss_altitude)
    end

    def valid?
      @valid
    end

    def populate_known_extensions
      @extensions.each do |key, value|
        case key
        when "HDM"
          @magnetic_heading = value.to_u16
        when "HDT"
          @true_heading = value.to_u16
        when "IAS"
          @air_speed = value.to_i32
        when "SIU"
          @satellites_in_use = value.to_i32
        when "TAS"
          @true_air_speed = value.to_i32
        when "WDI"
          @wind_direction = value.to_u16
        when "WSP"
          @wind_speed = value.to_i32
        end
      end
    end
  end
end
