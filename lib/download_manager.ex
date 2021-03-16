defmodule DownloadManager do
  @moduledoc """
  A PoC for downloading files from S3 using streams.
  """

  @megabyte 1_048_576

  @doc """
  Download a file from AWS in chunks using a Stream.

  This is useful to keep the memory consumption low while downloading
  big files. It is also useful if you want to send the response in
  chunks to the client using `Plug.Conn.send_chunked/3`.

  ## Example

      iex> client = AWS.Client.create("your-secret-key", "your-access-key", "region")
      iex> client = %{client | http_client: {DownloadManager.AWS.HTTPClient, []}}
      iex> stream = DownloadManager.aws_download_stream(client, "foo-bucket", "bar/baz-file.zip")
      iex> Stream.into(stream, File.stream!("my_file.html", [:append])) |> Stream.run()

  """
  def aws_s3_download_stream(%AWS.Client{} = client, bucket, path, chunk_size \\ @megabyte) do
    Stream.resource(
      fn ->
        {:ok, _, resp} =
          AWS.S3.head_object(
            client,
            bucket,
            path,
            %{}
          )

        {_, bytes} = List.keyfind(resp.headers, "content-length", 0)
        bytes = String.to_integer(bytes)

        %{total: bytes, remaining: bytes}
      end,
      fn track ->
        remaining = track.remaining

        if remaining == 0 do
          {:halt, track}
        else
          from = track.total - remaining

          {to, new_remaining} =
            if remaining >= chunk_size do
              to = from + chunk_size - 1

              {to, track.remaining - chunk_size}
            else
              {track.total - 1, 0}
            end

          # TODO: fix me in aws-beam/aws-elixir. It should return {:ok, response}
          {:error, {:unexpected_response, response}} =
            AWS.S3.get_object(
              client,
              bucket,
              path,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              "bytes=#{from}-#{to}"
            )

          {[response.body], %{track | remaining: new_remaining}}
        end
      end,
      fn _track ->
        :ok
      end
    )
  end
end
