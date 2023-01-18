module IGC
  class File
    # Identifier of the flight recorder
    property flight_recorder_id : String?

    # Headers of the file
    property headers : Headers = Headers.new

    # Task definition, if specified
    property task : Task?
  end
end
