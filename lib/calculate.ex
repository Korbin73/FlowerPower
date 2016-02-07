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

  @doc """
  Calculates the daily soil moisture for the given day in the data graph that is retrieve
  when calling the api service. The returned value will be a single number with unspecified 
  precision: 21.80029710232427
  """
  def get_average_soil_moisture([]), do: []
  def get_average_soil_moisture(data_graph) do
    list_of_timestamps = get_samples_from data_graph

    number_of_timestamps = Enum.count list_of_timestamps
    total_soil_moisture  =
      Enum.map(list_of_timestamps, fn(sample_map) -> Dict.get(sample_map, "vwc_percent")  end)
      |> Enum.sum
    total_soil_moisture / number_of_timestamps
  end

  @doc """
  Returns a keyword list with the hour, soil moisture percentage and light intensity.
  Example:
    [{6, 23.911042707773333, 0.10000000000000002}, {7, 23.34991703012, 0.1}]
  """
  def get_light_tempurature([], _), do: []
  def get_light_tempurature(data_graph, sensor_read_date) do
      get_samples_from(data_graph)
      |> Enum.filter(fn sample -> Date.compare(get_date_from_sample(sample), sensor_read_date, :days) == 0 end)
      |> Enum.group_by(&get_date_from_sample(&1).hour)
      |> Enum.map(&average_hourly_light_tempurature/1)
  end

  defp average_hourly_light_tempurature(grouped_hourly_map) do
    {_, hourly_map} = grouped_hourly_map

    read_date = List.first(hourly_map) |> Dict.get("capture_ts")
    hour_block = DateFormat.parse(read_date, "{ISOz}") |> extract_hour

    number_of_reads = Enum.count hourly_map
    total_tempurature = Enum.map(hourly_map, fn(x) -> Dict.get(x, "air_temperature_celsius") end)
                            |> Enum.sum
    total_light = Enum.map(hourly_map, fn(x) -> Dict.get(x, "par_umole_m2s") end)
                            |> Enum.sum                      

     {hour_block,total_tempurature/number_of_reads, total_light/number_of_reads}
  end

  @doc """
  Gets the lowest moisture measurement of the day based on the day the sensor reading was taken
  that's in the garden data graph. The sensor takes a reading every 15 minutes.

  It returns a tuple in the following format:
  {moisture_rate, timestamp}
  """
  def get_lowest_moisture([], _), do: []
  def get_lowest_moisture(data_graph, sensor_read_date) do
  	filter_samples(data_graph, sensor_read_date, fn(filtered_sample) -> 
  		Enum.min_by(filtered_sample, fn sample -> Dict.get(sample, "vwc_percent") end)
  	end)
  end

  @doc """
  Gets the highest moisture measurement of the day based on the day the sensor reading was taken
  that's in the garden data graph. The sensor takes a reading every 15 minutes.

  It returns a tuple in the following format:
  {moisture_rate, timestamp}
  """
  def get_highest_moisture([], _), do: []
  def get_highest_moisture(data_graph, sensor_read_date) do
  	filter_samples(data_graph, sensor_read_date, fn(filtered_sample) -> 
  		Enum.max_by(filtered_sample,fn sample -> Dict.get(sample, "vwc_percent")  end)
  	end)
  end

  @doc """
  Returns a keyword list that has the hour and the soil percentage for that hour in the
  following format:
    [{6, 22.639327889313865}, {7, 22.3569090340487}]
  """
  def get_hourly_avg_soil_percentage([], _), do: []
  def get_hourly_avg_soil_percentage(data_graph, sensor_read_date) do
  	get_samples_from(data_graph)
      |> Enum.filter(fn sample -> Date.compare(get_date_from_sample(sample), sensor_read_date, :days) == 0 end)
			|> Enum.group_by(&get_date_from_sample(&1).hour)
			|> Enum.map(&average_hourly_data/1)
  end

  defp average_hourly_data(grouped_hourly_map) do
  	{_, hourly_map} = grouped_hourly_map

  	read_date = List.first(hourly_map) |> Dict.get("capture_ts") 
  	hour_block = DateFormat.parse(read_date, "{ISOz}") |> extract_hour

  	number_of_reads = Enum.count hourly_map
  	total_soil_percentage = Enum.map(hourly_map, fn(x) -> Dict.get(x, "vwc_percent") end)
  													|> Enum.sum
  	 {hour_block,total_soil_percentage/number_of_reads}
  end

  defp extract_hour({_, time_stamp}), do: time_stamp.hour

  defp filter_samples(graph, sensor_read_date, criteria) do
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
  defp get_samples_from(data_graph), do: data_graph |> Dict.get("samples")
end
