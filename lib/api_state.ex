defmodule FlowerPower.StateManager do
	require Logger

	@name __MODULE__

	@doc """
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

	@doc """
	Gets the garden data graph from the Map that is stored by a key that is create by the
	calling function.
	"""
	def get({keyname}) do
		Agent.get @name, fn map -> 
			{:ok, Map.get(map, keyname)}
		end
	end

	defp get_proper_map(true, _, _, _),                  do: Map.new
	defp get_proper_map(false, map, keyname, map_value), do: Map.put(map, keyname, map_value)
end

defmodule FlowerPower.ApiCache do
	require Logger
	use Timex
	alias FlowerPower.StateManager

	@doc """
	Start the cache manager that will hold the results of the 
	"""
	def start, do: StateManager.start

	@doc """
	Calls the flower power api with the passed in parameters with the following format:
		{credentials, from_date, to_date}

	The api client is a callback for actually calling the flower power api rest service.

	If the date range is longer than 2 weeks, the flower power api will send back an error 
	message asking to narrow the search. When the api successfully returns the garden data
	it's saved in the State manager so it can be retrieved the next time a api call in made 
	within the same hour. This is useful for getting the same data within the same hour so 
	other calculations like the calculate module can be used without hitting the service to
	get the same data again.
	"""
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
end

