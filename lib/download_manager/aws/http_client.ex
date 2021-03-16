defmodule DownloadManager.AWS.HTTPClient do
  @behaviour AWS.HTTPClient

  alias DownloadManager.MyFinch

  @moduledoc false

  @impl true
  def request(method, url, body, headers, options) do
    request = Finch.build(method, url, headers, body)

    case Finch.request(request, MyFinch, options) do
      {:ok, %Finch.Response{} = resp} ->
        {:ok, %{status_code: resp.status, headers: resp.headers, body: resp.body}}

      {:error, _} ->
        {:error, "http error"}
    end
  end
end
