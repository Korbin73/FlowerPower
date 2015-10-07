defmodule ApiStateManagerTests do
	use ExUnit.Case, async: true
  use Timex
  use ShouldI
  alias FlowerPower.ApiCache
  alias FlowerPower.StateManager

  with "api state server" do
  	setup context do
  		{:ok, agent} = StateManager.start
  		context |> Dict.put "agent", agent
  	end

  	should "return the process id when starting", context do
  		assert Map.has_key?(context, "agent") == true
  	end

  	should "ok when add a map to the state manager", context do
  		params = {context["agent"], "garden", %{"samples" => "test"}}
  		assert StateManager.update_cache(params) == :ok    
  	end

  	should "get map from state manager", context do
  		params = {context["agent"], "garden", %{"samples" => "test"}}
  		StateManager.update_cache(params)

  		assert StateManager.get({context["agent"], "garden"}) |> Map.size == 1
  	end
  end

  with "using the api gateway" do
  	setup context do
  		context |> Dict.put "api", _flower_power_api = fn _, _, _ -> 
  			assert true, "means the service has called to this point"
  			%{"fake" => "data"} 
  		end
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