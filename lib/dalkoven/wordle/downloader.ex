defmodule Dalkoven.Wordle.Downloader do
  @doc """
  Fetches Wordle puzzle metadata from the NY Times API and persists it to the database.

  ## Parameters

  * `date` - String representing the date to fetch in a format accepted by the NY Times API
  * `opts` - Keyword list of options:
    * `:on_conflict` - Ecto option for conflicts (default: `:raise`)

  ## Returns

  * `{:ok, puzzle}` - Successfully fetched, decoded, and persisted puzzle data
  * `{:error, reason}` - An error occurred during fetch, decode, or database operation
  """
  def get_puzzle(date, opts \\ []) do
    case HTTPoison.get("https://www.nytimes.com/svc/wordle/v2/#{date}.json") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, json} ->
            result = %Dalkoven.Wordle.Puzzle{}
            |> Dalkoven.Wordle.Puzzle.changeset(json)
            |> Dalkoven.Repo.insert(on_conflict: Keyword.get(opts, :on_conflict, :raise))
            case result do
              {:ok, struct} -> struct
              {:error, insert_error} ->
                case Dalkoven.Repo.get_by(Dalkoven.Wordle.Puzzle, id: json["id"]) do
                  nil -> {:error, insert_error}
                  existing -> {:ok, existing}
                end
            end

          {:error, error} ->
            {:error, "Decode for #{date} returned error: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Fetch #{date} returned code: #{status_code}"}

      {:error, error} ->
        {:error, "Fetch #{date} returned error: #{inspect(error)}"}
    end
  end

  def get_all_puzzles(opts \\ []) do
    today = Date.utc_today()
    get_all_puzzles_until_failure(today, 0, opts)
  end

  def get_all_puzzles_until_failure(date, count, opts \\ []) do
    case get_puzzle(date |> Date.to_string(), opts) do
      {:ok, _puzzle} ->
        get_all_puzzles_until_failure(Date.add(date, -1), count + 1, opts)

      _ ->
        count
    end
  end
end
