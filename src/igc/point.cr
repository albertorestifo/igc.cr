module IGC
  struct Point
    property coords : LatLon
    property description : String?

    def initialize(@coords, @description = nil)
    end

    def self.zero
      new(LatLon.zero)
    end
  end
end
