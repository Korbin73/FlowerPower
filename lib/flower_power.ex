defmodule FlowerPower.Api do
  @moduledoc"""
  This module is used to get the raw data graph from parrots web service
  """

  alias Poison.Parser
  alias FlowerPower.Extractor
  use Timex

  @url_base_path "https://apiflowerpower.parrot.com"

  def get_garden_data(credentials, begin_date, end_date) do
    url = @url_base_path <> "/user/v1/authenticate"

    {:ok, response} = HTTPoison.get url, [], params: credentials
    access_token = get_access_token_from(response)

    get_sensor_info( access_token )
      |> get_location_params
      |> get_garden_by_location(access_token, begin_date, end_date)
      |> parse_body
  end

  defp parse_body({:ok, garden_response}), do: Parser.parse!(garden_response.body)

  defp get_garden_by_location(location, access_token, from_date_format, end_date_format ) 
    when is_binary(from_date_format) == false and is_binary(end_date_format) == false
    do
      {:ok, from_date} = from_date_format |> DateFormat.format("{ISOz}")
      {:ok, end_date}  = end_date_format  |> DateFormat.format("{ISOz}")

      get_garden_by_location(location, access_token, from_date, end_date )
  end

  defp get_garden_by_location(location, access_token, from_date, end_date) do
    date_range = %{"from_datetime_utc": from_date, "to_datetime_utc": end_date}
    
    @url_base_path <> "/sensor_data/v2/sample/location/#{location}"
      |> HTTPoison.get [{:Authorization, "Bearer #{access_token}"}], params: date_range
  end

  defp get_access_token_from(response) do
    Parser.parse!(response.body) |> Dict.get "access_token"
  end

  defp get_location_params({:ok, response}) do
      # If we had more that one sensor, the service would have returned more in
      # the array
      location_list = Parser.parse!(response.body)
      List.first(location_list["locations"]) |> Dict.get "location_identifier"
  end

  defp get_sensor_info(access_token) do
    @url_base_path <> "/sensor_data/v3/sync"
      |> HTTPoison.get [{:Authorization, "Bearer #{access_token}"}]
  end
end
