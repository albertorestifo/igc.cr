module IGC
  struct Fix
    # Location of the fix
    property coords : LatLon

    # Time at which the fix was recorded
    property time : Time

    # Is the fix valid?
    property valid : Bool

    # Pressure altitude in meters
    property pressure_altitude : Int32

    # GPS altitude in meters
    property gnss_altitude : Int32

    # Extensions contained in the fix record
    property extensions : Hash(String, String) = {} of String => String

    def initialize(@coords, @time, @valid, @pressure_altitude, @gnss_altitude)
    end

    def valid?
      @valid
    end
  end
end
