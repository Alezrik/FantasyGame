# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Platform.Repo.insert!(%Platform.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _user} =
  Platform.Accounts.create_user(%{name: "admin", email: "here@there.com", password: "password"})

{:ok, world} = Platform.Worlds.create_world(%{name: "default world"})
{:ok, zome} = Platform.Zones.create_zone(%{name: "default start zone", world_id: world.id})
