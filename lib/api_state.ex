defmodule FlowerPower.StateManager do
	def start, do: Agent.start_link fn -> %{} end

	def update_cache({agent, keyname, map_value}), do:
		Agent.update agent, fn map -> Map.put(map, keyname, map_value) end
	
	def get({agent, keyname}), do: 
		Agent.get agent, fn map -> Map.get(map, keyname) end
end

defmodule FlowerPower.ApiCache do
	import FlowerPower.Api
	require Logger
	use Timex
	alias FlowerPower.StateManager

	def call_api( api_parameters,api_client) do
		{credentials, date_from, date_to} = api_parameters

		{:ok, agent}   = StateManager.start
		cached_results = StateManager.get { agent, create_timestamp(date_from, date_to) }
		
		case cached_results do
			{:ok, results} ->
				results
			nil ->
				IO.puts "calling the service"
				garden_data = api_client.(credentials, date_from, date_to)
				StateManager.update_cache {agent, create_timestamp(date_from, date_to), garden_data}
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

