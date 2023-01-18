module IGC
  struct LatLon
    property lat : Float32
    property lon : Float32

    def initialize(@lat, @lon)
    end

    def self.zero
      new(0.0, 0.0)
    end

    # Create a LatLon point from an IGC IO
    def self.from_igc(io : IO)
      lat = self.read_igc_coords(io)

      pole = io.read_char
      if pole == 'S'
        lat *= -1
      end

      lng = self.read_igc_coords(io, 3)
      card = io.read_char
      if card == 'W'
        lng *= -1
      end

      new(lat, lng)
    end

    # Reads a coordinate pair from an IGC file
    private def self.read_igc_coords(io : IO, degrees_size = 2) : Float32
      deg = io.read_string(degrees_size).to_f32
      min = io.read_string(5).to_f32 / 1000 / 60

      (deg + min).round(6)
    end
  end
end
