defmodule CalculateTest do
  use ExUnit.Case, async: true
  alias FlowerPower.Calculate
  use Timex

  test "average daily soil moisture" do
    average = GardenData.one_day() |> Calculate.get_average_soil_moisture()
    assert average == 21.80029710232427
  end

  test "lowest soil moisture in the day with timestamp" do
    sensor_read_date = Date.from({2015, 9, 18})
    {moisture_rate, timestamp} = GardenData.one_day() |> Calculate.get_lowest_moisture(sensor_read_date)

    assert moisture_rate == 20.9977674636631
    assert timestamp == "2015-09-18T12:10:00Z"
  end

  test "highest soil moisture in the day with timestamp" do
    sensor_read_date = Date.from({2015, 9, 18})
    {moisture, timestamp} = GardenData.one_day() |> Calculate.get_highest_moisture(sensor_read_date)

    assert moisture == 22.8500248532912
    assert timestamp == "2015-09-18T06:25:00Z"
  end

  test "Get hourly average data by day" do
    sensor_read_date = Date.from({2015, 9, 18})
    hourly_avg_list = GardenData.one_day() |> Calculate.get_hourly_avgs(sensor_read_date)
    
    assert Enum.count(hourly_avg_list) == 7
  end

  test "Hourly light intensity with tempurature" do
    
  end
end
