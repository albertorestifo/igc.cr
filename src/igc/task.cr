module IGC
  # Task repsents a Task declaration in an IGC file
  class Task
    property time : Time
    property description : String
    property start : Point = Point.zero
    property finish : Point = Point.zero
    property turn_points : Array(Point)? = nil
    property takeoff : Point? = nil
    property landing : Point? = nil

    def initialize(@time, @description, @start, @finish, @turn_points, @takeoff, @landing)
    end

    # Creates a basic task definition by parsing the first C record line
    def self.from_c_header(io : IO)
      # First byte is the identifier
      io.skip(1)

      # Next 12 bytes are the date and time
      time = Time.parse(io.read_string(12), "%d%m%y%H%M%S", Time::Location::UTC)

      # The next 6 bytes are the "date of flight", which is legacy so we just skip
      io.skip(6)

      # Next 4 bytes are legacy as well
      io.skip(4)

      # Next 2 bytes is the number of turn-points, but we don't really use this
      io.skip(2)

      description = io.gets

      new(time: time, description: description)
    end

    # Add a new waypoint from a C line
    def parse_c_line(io : IO)
      # First byte is the identifier
      io.skip(1)

      coords = LatLon.from_igc(io)

      # Read the first 2 bytes, which will identify the kind of waypoint
      # Then read the description until the end of the line
      case prefix = io.read_string(2)
      when "TA"
        # TAKEOFF
        io.skip(5)
        @takeoff = Point.new(coords, io.gets)
      when "TU"
        io.skip(2)
        @turn_points ||= [] of LatLon
        @turn_points << Point.new(coords, io.gets)
      when "ST"
        # START
        io.skip(3)
        @start = Point.new(coords, io.gets)
      when "FI"
        # FINISH
        io.skip(4)
        @finish = Point.new(coords, io.gets)
      else
        raise ParseError.new("Unknown waypoint type in C line: #{prefix}", io)
      end
    end
  end
end
