defmodule ApiStateManagerTests do
	use ExUnit.Case, async: true
  use Timex
  use ShouldI
  alias FlowerPower.ApiCache
  alias FlowerPower.StateManager

  having "api state server" do
  	setup context do
  		{:ok, agent} = StateManager.start
  		context |> Dict.put("agent", agent)
  	end

  	should "ok when add a map to the state manager", _context do
  		assert StateManager.update_cache({"any_keyname", %{"samples" => "test"}}) == :ok
  	end

  	should "get map from state manager", _context do
  		StateManager.update_cache({"any_keyname", %{"samples" => "test"}})

  		assert StateManager.get({"any_keyname"})
  		|> pluck_map
  		|> Map.size == 1
  	end

  	defp pluck_map({:ok, retrieved_map}), do: retrieved_map
  end

  having "using the api gateway" do
  	setup context do
  		{:ok, _agent} = FlowerPower.ApiCache.start
  		context |> Dict.put("api", _flower_power_api = fn _, _, _ ->
  			assert true, "means the service has called to this point"
  			%{"fake" => "data"}
  		end)
  	end

  	should "call the api service on first call",context do
  		api_params = {%{}, TestUtils.get_yesterdays_date, TestUtils.get_todays_date}
  		ApiCache.call_api(api_params, context["api"])
  	end
  end
end

defmodule TestUtils do
	use Timex

	def get_yesterdays_date, do: Date.now |> Date.subtract(Time.to_timestamp(2, :days))
	def get_todays_date,     do: Date.now

	def get_yesterdays_date_format do
		Date.now
	  |> Date.subtract(Time.to_timestamp(2, :days))
	  |> DateFormat.format("{ISO}")
	  |> pluck_date
	end

	def get_todays_date_format do
		Date.now
	  |> DateFormat.format("{ISO}")
	  |> pluck_date
	end

	defp pluck_date({:ok, date}), do: date
end
