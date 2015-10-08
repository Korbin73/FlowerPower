defmodule FlowerPower.StateManager do
	require Logger

	@name __MODULE__

	@doc"""
	Starts the agent process
	"""
	def start, do: Agent.start_link fn -> %{} end, name: @name

	@doc """
	Updates the cache with the a new garden data graph
	"""
	def update_cache({keyname, map_value}) do
		Agent.update(@name, fn map -> 
			get_proper_map(Map.size(map) > 0, map, keyname, map_value)
		end)
	end

	def get({keyname}) do
		Agent.get @name, fn map -> 
			{:ok, Map.get(map, keyname)}
		end
	end

	defp get_proper_map(true, _, _, _),                  do: Map.new
	defp get_proper_map(false, map, keyname, map_value), do: Map.put(map, keyname, map_value)
end

defmodule FlowerPower.ApiCache do
	import FlowerPower.Api
	require Logger
	use Timex
	alias FlowerPower.StateManager

	@doc """
	Start the cache manager that will hold the results of the 
	"""
	def start, do: StateManager.start

	def call_api( api_parameters,api_client) do
		{credentials, date_from, date_to} = api_parameters
		
		cached_results = StateManager.get { create_timestamp(date_from, date_to) }
		
		case cached_results do
			{:ok, results}  when is_nil(results) == false ->
				results
			{:ok, nil} ->
				garden_data = api_client.(credentials, date_from, date_to)
				StateManager.update_cache {create_timestamp(date_from, date_to), garden_data}
				garden_data
		end
	end

	defp create_timestamp(date_from, date_to) do
		from_days   = Date.to_days(date_from) |> Integer.to_string 
		todays_date = Date.to_days(date_to)   |> Integer.to_string

		"#{from_days}_#{todays_date}"
	end

	defp pluck_date({:ok, date}), do: date
end

