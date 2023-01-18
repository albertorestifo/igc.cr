require "./spec_helper"

describe IGC do
  describe "parse" do
    it "parses the sample file provided in the official documentation" do
      parsed = File.open("spec/fixtures/official_example.igc") { |file| IGC.parse(file) }

      parsed.flight_recorder_id.should eq("CAMXYZ")

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
      task.takeoff.not_nil!.coords.lat.should eq(51.190315.to_f32)
      task.takeoff.not_nil!.coords.lon.should eq(-1.031917.to_f32)

      parsed.fixes.size.should eq(9)

      fix = parsed.fixes.first
      fix.should_not be_nil
      next if fix.nil?

      # I 03 36-38 FXA 39-40 SIU 41-43 ENL
      # B 16:02:40 5407121N 00249342W A 00280 00421 055 09 950

      fix.time.should eq(Time.utc(2019, 8, 16, 16, 2, 40))
      fix.coords.lat.should eq(54.118683.to_f32)
      fix.coords.lon.should eq(-2.822367.to_f32)
      fix.valid?.should be_true
      fix.pressure_altitude.should eq(280)
      fix.gnss_altitude.should eq(421)
      fix.extensions.size.should eq(3)
      fix.extensions["FXA"].should eq("055")
      fix.extensions["SIU"].should eq("09")
      fix.extensions["ENL"].should eq("950")
    end
  end
end
