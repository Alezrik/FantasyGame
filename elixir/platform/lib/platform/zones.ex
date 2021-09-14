defmodule Platform.Zones do
  @moduledoc """
  The Zones context.
  """

  import Ecto.Query, warn: false
  alias Platform.Repo

  alias Platform.Zones.Zone

  @doc """
  Returns the list of zones.

  ## Examples

      iex> list_zones()
      [%Zone{}, ...]

  """
  def list_zones do
    Repo.all(Zone)
  end

  @doc """
  Gets a single zone.

  Raises `Ecto.NoResultsError` if the Zone does not exist.

  ## Examples

      iex> get_zone!(123)
      %Zone{}

      iex> get_zone!(456)
      ** (Ecto.NoResultsError)

  """
  def get_zone!(id), do: Repo.get!(Zone, id)

  @doc """
  Creates a zone.

  ## Examples

      iex> create_zone(%{field: value})
      {:ok, %Zone{}}

      iex> create_zone(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_zone(attrs \\ %{}) do
    %Zone{}
    |> Zone.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a zone.

  ## Examples

      iex> update_zone(zone, %{field: new_value})
      {:ok, %Zone{}}

      iex> update_zone(zone, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_zone(%Zone{} = zone, attrs) do
    zone
    |> Zone.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a zone.

  ## Examples

      iex> delete_zone(zone)
      {:ok, %Zone{}}

      iex> delete_zone(zone)
      {:error, %Ecto.Changeset{}}

  """
  def delete_zone(%Zone{} = zone) do
    Repo.delete(zone)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking zone changes.

  ## Examples

      iex> change_zone(zone)
      %Ecto.Changeset{data: %Zone{}}

  """
  def change_zone(%Zone{} = zone, attrs \\ %{}) do
    Zone.changeset(zone, attrs)
  end
end
