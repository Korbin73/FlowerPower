defmodule FlowerPower.Credentials do
  defstruct [
    :grant_type,
    :client_id,
    :client_secret,
    :username,
    :password
  ]
end
