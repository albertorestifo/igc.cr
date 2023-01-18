require "./spec_helper"

describe IGC do
  describe "parse" do
    it "parses the sample file provided in the official documentation" do
      parsed = File.open("spec/fixtures/official_example.igc") { |file| IGC.parse(file) }

      parsed.flight_recorder_id.should eq("AMXYZ")

      # Validate headers
      parsed.headers.headers.size.should eq(13)
      parsed.headers.competition_class.should eq("20m Motor Glider")
      parsed.headers.competition_id.should eq("111")
      parsed.headers.date.should eq(Time.utc(2019, 8, 16))
      parsed.headers.flight_number.should eq(2)
      parsed.headers.flight_recorder_type.should eq("CambridgeCAI302")
      parsed.headers.glider_id.should eq("G-GLID")
      parsed.headers.glider_type.should eq("Arcus M")
      parsed.headers.pilot.should eq("Bloggs Bill D")
      parsed.headers.firmware_version.should eq("6.4")
      parsed.headers.hardware_version.should eq("3.0")

      # Validate task definition
      parsed.task.should_not be_nil
      task = parsed.task
      next if task.nil?
      task.time.should eq(Time.utc(2015, 8, 21, 9, 38, 41))
      task.description.should eq("500K Triangle")
      task.takeoff.not_nil!.description.should eq("Lasham Clubhouse")
      task.takeoff.not_nil!.coords.lat.should eq(6.856983)
      task.takeoff.not_nil!.coords.lon.should eq(-1.031916)
    end
  end
end
