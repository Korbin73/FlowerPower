defmodule FlowerPower.Diagnostics do
  @moduledoc"""
  This module is used to help writing api outputs to disk for easier inspection than 
  iex.
  """
  def write_out_json_to_file({:ok, sample_response}) do
    {:ok, json_file} = File.open("json_output",[:write])
    IO.binwrite json_file, sample_response.body
    File.close(json_file)
  end

  def write_out_map_to_file(map) do
    {:ok, output_file} = File.open("output",[:write])
    IO.binwrite(output_file, inspect(map, [pretty: true, limit: 400]))
    File.close(output_file)
  end
end
