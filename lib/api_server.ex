defmodule FlowerPower.ApiServer do
	@moduledoc """
	Generic server for calling the flower power api and caching the results based on the date
	range that has been used on previous requests.
	"""
	use GenServer
	import FlowerPower.Api
	require Logger
	use Timex


	def start_link(opt \\ []) do
		GenServer.start_link(__MODULE__, :ok, opt)
	end

	@doc """
	Calls the server the api that checks to see if the service has been called with
	the same parameters before; if it has, it gets the garden data from the dictionary

	The api parameters is a tuple in the following format:
		{credentials, date_from, date_to}

		The date_from and date_to are timex dates
	"""
	def call_api(server, api_parameters) do
		GenServer.call(server, api_parameters)
	end

	def handle_info(info,state) do
		Logger.info info
		Logger.info state
	end

	## Server api
	@doc """
	This function handles calling the flower power api service
	"""
	def handle_call(api_parameters, _from, connection_dict) do
		{credentials, date_from, date_to} = api_parameters
		fetch_success = check_previous_call(api_parameters, connection_dict)

		formatted_from_date = date_from |> DateFormat.format("{ISO}") |> pluck_date

		case fetch_success do
			{:ok, response} ->
				{:reply, response, connection_dict}
			:error ->
				garden_data = get_garden_data(credentials, formatted_from_date, date_to)
				new_dict = HashDict.put(connection_dict, create_timestamp(date_from, date_to), garden_data)
				{:reply, new_dict, connection_dict}
		end
	end

	def init(:ok) do
		{:ok, HashDict.new}
	end

	defp create_timestamp(date_from, date_to) do
		from_days   = Date.to_days(date_from) |> Integer.to_string
		todays_date = Date.to_days(date_to)   |> Integer.to_string

		"#{from_days}_#{todays_date}"
	end

	defp check_previous_call({_credentials, date_from, date_to},connection_dict) do
		# Check time based on the day instead of down to the second.
		# the key in he dictionary will be the date range
		timestamp = create_timestamp(date_from, date_to)

		HashDict.fetch(connection_dict, timestamp)
	end

	defp pluck_date({:ok, date}), do: date
end
