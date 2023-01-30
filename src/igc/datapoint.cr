module IGC
  struct Datapoint
    property time : Time
    property data : Hash(String, String) = {} of String => String
  end
end
