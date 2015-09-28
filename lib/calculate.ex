defmodule FlowerPower.Calculate do
	@moduledoc"""
	This module takes the data structure from the parrot flower power api calls and returns data 
	structures that are more digestable.

	Steps to using this module:
		1. Query api with a date range to get the data from the parrots web service
		2. Pass the data graph to one of these functions to transform the data to a data structure
		   thats easier to reason about when used for situations like charting
	"""
	use Timex

  def get_average_soil_moisture([]), do: []
  def get_average_soil_moisture(data_graph) do
    list_of_timestamps = get_samples_from data_graph

    number_of_timestamps = Enum.count list_of_timestamps
    total_soil_moisture  =
      Enum.map(list_of_timestamps, fn(sample_map) -> Dict.get(sample_map, "vwc_percent")  end)
      |> Enum.sum
    total_soil_moisture / number_of_timestamps
  end

  def get_light_tempurature([], _), do: []
  def get_light_tempurature(data_graph, sensor_read_date) do
      get_samples_from(data_graph)
      |> Enum.filter(fn sample -> Date.compare(get_date_from_sample(sample), sensor_read_date, :days) == 0 end)
      |> Enum.group_by(&get_date_from_sample(&1).hour)
      |> Enum.map(&average_hourly_light_tempurature/1)
  end

  defp average_hourly_light_tempurature(grouped_hourly_map) do
    {_, hourly_map} = grouped_hourly_map

    read_date = List.first(hourly_map) |> Dict.get "capture_ts" 
    hour_block = DateFormat.parse(read_date, "{ISOz}") |> extract_hour

    number_of_reads = Enum.count hourly_map
    total_tempurature = Enum.map(hourly_map, fn(x) -> Dict.get(x, "air_temperature_celsius") end)
                            |> Enum.sum
    total_light = Enum.map(hourly_map, fn(x) -> Dict.get(x, "par_umole_m2s") end)
                            |> Enum.sum                      

     {hour_block,total_tempurature/number_of_reads, total_light/number_of_reads}
  end

  def get_lowest_moisture([], _), do: []
  def get_lowest_moisture(data_graph, sensor_read_date) do
  	filter_samples(data_graph, sensor_read_date, fn(filtered_sample) -> 
  		Enum.min_by(filtered_sample, fn sample -> Dict.get(sample, "vwc_percent") end)
  	end)
  end

  def get_highest_moisture([], _), do: []
  def get_highest_moisture(data_graph, sensor_read_date) do
  	filter_samples(data_graph, sensor_read_date, fn(filtered_sample) -> 
  		Enum.max_by(filtered_sample,fn sample -> Dict.get(sample, "vwc_percent")  end)
  	end)
  end

  def get_hourly_avgs([], _), do: []
  def get_hourly_avgs(data_graph, sensor_read_date) do
  	get_samples_from(data_graph)
      |> Enum.filter(fn sample -> Date.compare(get_date_from_sample(sample), sensor_read_date, :days) == 0 end)
			|> Enum.group_by(&get_date_from_sample(&1).hour)
			|> Enum.map(&average_hourly_data/1)
  end

  defp average_hourly_data(grouped_hourly_map) do
  	{_, hourly_map} = grouped_hourly_map

  	read_date = List.first(hourly_map) |> Dict.get "capture_ts" 
  	hour_block = DateFormat.parse(read_date, "{ISOz}") |> extract_hour

  	number_of_reads = Enum.count hourly_map
  	total_soil_percentage = Enum.map(hourly_map, fn(x) -> Dict.get(x, "vwc_percent") end)
  													|> Enum.sum
  	 {hour_block,total_soil_percentage/number_of_reads}
  end

  defp extract_hour({_, time_stamp}), do: time_stamp.hour
  
  def filter_samples(graph, sensor_read_date, criteria) do
  	list_of_timestamps = get_samples_from graph
  	return_tuple =
	  	list_of_timestamps 
	  		|> Enum.filter(fn sample -> Date.compare(get_date_from_sample(sample), sensor_read_date, :days) == 0 end)
	  		|> criteria.()

  	{Dict.get(return_tuple,"vwc_percent"),Dict.get(return_tuple, "capture_ts")}
  end
  
  defp get_date_from_sample(sample) do
  	{:ok, date} = Dict.get(sample, "capture_ts") |> DateFormat.parse("{ISOz}")
  	date
  end
  defp get_samples_from(data_graph), do: data_graph |> Dict.get "samples"
end
