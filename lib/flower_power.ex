defmodule FlowerPower.Api do
  @moduledoc"""
  This module is used to get the raw data graph from parrots web service
  """

  alias Poison.Parser
  alias FlowerPower.Extractor
  use Timex

  @type year  :: non_neg_integer
  @type month :: non_neg_integer
  @type day   :: non_neg_integer

  @url_base_path "https://apiflowerpower.parrot.com"

  @doc """
  Calls the flower power api to get the garden data based on the parameters.
  """
  @spec get_garden_data(%FlowerPower.Credentials{}, {year, month, day}, {year,month,day}) :: %{}
  def get_garden_data(credentials, begin_date, end_date) do
      token = get_access_token(credentials)

      token
      |> get_sensor_info()
      |> get_location_params
      |> get_garden_by_location(token, begin_date, end_date)
      |> parse_body
  end

  @spec get_sync_data(%FlowerPower.Credentials{}) :: %{}
  def get_sync_data(credentials) do
    get_access_token(credentials)
    |> get_sensor_info()
    |> parse_body
  end

  defp get_access_token(credentials) do
    url = @url_base_path <> "/user/v1/authenticate"

    {:ok, response} = HTTPoison.get url, [], params: credentials
    get_access_token_from(response)
  end

  defp parse_body({:ok, garden_response}), do: Parser.parse!(garden_response.body)
  defp pluck_date({:ok, date}), do: date

  defp get_garden_by_location(location, access_token, from_date, end_date) do
    date_range = %{
      "from_datetime_utc": format_from_erlang_date(from_date) |> pluck_date,
      "to_datetime_utc":   format_from_erlang_date(end_date)  |> pluck_date
    }

    @url_base_path <> "/sensor_data/v2/sample/location/#{location}"
      |> HTTPoison.get([{:Authorization, "Bearer #{access_token}"}], params: date_range)
  end

  defp format_from_erlang_date(from_date) do
    Date.from(from_date)
    |> DateFormat.format("{YYYY}-{M}-{D} 12:00:00")
  end

  defp get_access_token_from(response) do
    Parser.parse!(response.body) |> Dict.get("access_token")
  end

  defp get_location_params({:ok, response}) do
      # If we had more that one sensor, the service would have returned more in
      # the array
      location_list = Parser.parse!(response.body)
      List.first(location_list["locations"]) |> Dict.get("location_identifier")
  end

  defp get_sensor_info(access_token) do
    @url_base_path <> "/sensor_data/v3/sync"
      |> HTTPoison.get([{:Authorization, "Bearer #{access_token}"}])
  end
end
