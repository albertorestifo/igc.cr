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

    def initialize(@time, @description)
    end

    # Creates a task definition by parsing an IGC file
    def self.from_igc(io : IO)
      # At first, we're being passed the first line, which contains the shared information

      # Next 12 bytes are the date and time
      time = Time.parse(io.read_string(12), "%d%m%y%H%M%S", Time::Location::UTC)

      # The next 6 bytes are the "date of flight", which is legacy so we just skip
      io.skip(6)

      # Next 4 bytes are legacy as well
      io.skip(4)

      # Next 2 bytes is the number of turn-points, but we don't really use this
      io.skip(2)

      # The rest of the first line is the description
      description = io.read_line

      task = new(time: time, description: description)

      # Check if the next line is a C line, which contains waypoints
      loop do
        next_buff = io.peek
        break if next_buff.nil?
        break if next_buff.empty?
        break unless next_buff[0].unsafe_chr == 'C'
        task.parse_igc_waypoint(io)
      end
    end

    # Add a new waypoint from a C line
    def parse_igc_waypoint(io : IO)
      # Skip the first character as it's always a C
      io.skip(1)

      coords = LatLon.from_igc(io)

      # Read the first 2 bytes, which will identify the kind of waypoint
      # Then read the description until the end of the line
      case prefix = io.read_string(2)
      when "TA"
        # TAKEOFF
        io.skip(5)
        @takeoff = Point.new(coords, io.read_line)
      when "TU"
        io.skip(2)
        tp = @turn_points ||= [] of Point
        tp << Point.new(coords, io.read_line)
        @turn_points = tp
      when "ST"
        # START
        io.skip(3)
        @start = Point.new(coords, io.read_line)
      when "LA"
        # LANDING
        io.skip(5)
        @landing = Point.new(coords, io.read_line)
      when "FI"
        # FINISH
        io.skip(4)
        @finish = Point.new(coords, io.read_line)
      else
        raise ParseError.new("Unknown waypoint type in C line: #{prefix}", io)
      end
    end
  end
end
