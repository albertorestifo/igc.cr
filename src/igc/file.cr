module IGC
  class File
    # Identifier of the flight recorder
    property flight_recorder_id : String?

    # Headers of the file
    property headers : Headers = Headers.new

    # Task definition, if specified
    property task : Task?

    # Security signature found on the G line
    property security_signature : String?

    # All the fixes recorded in the file
    property fixes : Array(Fix) = [] of Fix
  end
end
