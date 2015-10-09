defmodule CalculateTest do
  use ExUnit.Case, async: true
  alias FlowerPower.Calculate
  use Timex
  use ShouldI

  should "get average daily soil moisture" do
    average = GardenData.one_day() |> Calculate.get_average_soil_moisture()

    assert average == 21.80029710232427
  end

  should "return empty list when passing empty list as data graph" do
    average = Calculate.get_average_soil_moisture([])

    assert average == []
  end

  should "return lowest soil moisture in the day with timestamp" do
    sensor_read_date = Date.from({2015, 9, 18})
    {moisture_rate, timestamp} = GardenData.one_day() |> Calculate.get_lowest_moisture(sensor_read_date)

    assert moisture_rate == 20.9977674636631
    assert timestamp == "2015-09-18T12:10:00Z"
  end

  should "return highest soil moisture in the day with timestamp" do
    sensor_read_date = Date.from({2015, 9, 18})
    {moisture, timestamp} = GardenData.one_day() |> Calculate.get_highest_moisture(sensor_read_date)

    assert moisture == 22.8500248532912
    assert timestamp == "2015-09-18T06:25:00Z"
  end

  should "get hourly average data by day" do
    sensor_read_date = Date.from({2015, 9, 18})
    hourly_avg_list = GardenData.one_day() 
    |> Calculate.get_hourly_avg_soil_percentage(sensor_read_date)

    assert Enum.count(hourly_avg_list) == 7
  end

  should "return hourly light intensity with tempurature" do
    sensor_read_date = Date.from({2015, 9, 18})
    light_tempurature = GardenData.one_day() |> Calculate.get_light_tempurature(sensor_read_date)

    assert Enum.count(light_tempurature) == 7
  end

  should "return empty list when passing an empty data graph when getting light and temp" do
    sensor_read_date = Date.from({2015, 9,18})
    light_tempurature = [] |> Calculate.get_light_tempurature(sensor_read_date)

    assert Enum.count(light_tempurature) == 0
  end

  should "return empty list when passing an empty data graph when getting lowest moisture rate" do
    sensor_read_date = Date.from({2015, 9, 18})
    moisture_rate = [] |> Calculate.get_lowest_moisture(sensor_read_date)

    assert Enum.count(moisture_rate) == 0
  end

  should "return empty list when passing an empty data graph when getting highest moisture rate" do
    sensor_read_date = Date.from({2015, 9, 18})
    moisture_rate = [] |> Calculate.get_highest_moisture(sensor_read_date)

    assert Enum.count(moisture_rate) == 0
  end

  should "return empty list when passing an empty data graph when getting hourly averages" do
    sensor_read_date = Date.from({2015, 9, 18})
    moisture_rate = [] 
    |> Calculate.get_hourly_avg_soil_percentage(sensor_read_date)

    assert Enum.count(moisture_rate) == 0
  end
end
