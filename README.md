Flower Power
===========

Parrot's flower power cloud service api wrapper written in Elixir.

Before you get started, you will need an oauth token from:
[parrot api](https://apiflowerpower.parrot.com/api_access/signup)

Usage
-----------------

1. To get the data from parrot's webservice it simply needs the credentials and a date range. Below
   are details about the credentials

	```elixir
	credentials = %{
	  "grant_type": "<you password goes here>",
	  "username": "<username goes here; likely email address>",
	  "password": "<chosen password>",
	  "client_id": "<same as username>",
	  "client_secret": "<passcode given when you sign up for parrots api service>"
	}
	```
	Sample use:

	```elixir
	defmodule App do
		def get_yesterdays_date do
			Date.now
		  |> Date.subtract(Time.to_timestamp(2, :days))
		  |> DateFormat.format("{ISO}")
		  |> pluck_date
		end

		def get_todays_date do
			Date.now
		  |> DateFormat.format("{ISO}")
		  |> pluck_date
		end
		
		defp pluck_date({:ok, date}), do: date
	end

	FlowerPower.Api.get_garden_data(credentials, App.get_yesterdays_date, App.get_todays_date)

	```

2. The calculate module provides transformations using the data graph from the service.

Items left to do:
-----------------
TODO: Add to hex
