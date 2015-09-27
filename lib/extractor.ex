defmodule FlowerPower.Extractor do
  alias Poison.Parser
  alias FlowerPower.Samples
  use Timex

  def list_of_timestamps(query_data) do
    list_of_samples =
      query_data
      |> Dict.get "samples"

    for n <- list_of_samples, do: Samples.pluck_date(n) |> Samples.convert_to_readable_date
  end
end

defmodule FlowerPower.Samples do
  use Timex

  def pluck_date(single_sample), do: Dict.get(single_sample, "capture_ts")

  def convert_to_readable_date(iso_date), do: DateFormat.parse(iso_date,"{ISOz}") |> get_only_date
  def get_only_date({:ok, date}), do: date
end
