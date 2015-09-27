defmodule ExtractorTest do
  use ExUnit.Case, async: true
  alias FlowerPower.Extractor

  test "When given data from the api a list of dates should be return" do
      timestamp_list = Extractor.list_of_timestamps(GardenData.one_day)

      assert Enum.count(timestamp_list) > 0
  end
end
