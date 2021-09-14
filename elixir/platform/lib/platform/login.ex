defmodule Platform.Login do
  @moduledoc false
  require Logger

  def login_user(%{:deviceid => deviceid, :username => username, :password => password})
      when not is_nil(deviceid) and not is_nil(username) do
    Logger.info("login user")

    case verify_login_parameters(deviceid, username, password) do
      {:error, reason} ->
        {:error, reason}

      {:ok} ->
        Logger.info("Checking User Credentials")

        case process_credentials(username, password) do
          {:error, reason} ->
            {:error, reason}

          {:ok, token, hash_string, login_id} ->
            Logger.info("add login to tracker")

#            Platform.LoginTracker.add_login(
#              login_id,
#              hash_string,
#              deviceid,
#              token,
#              Atom.to_string(node()),
#              "login_#{login_id}"
#            )

            Platform.Login.LoginWorkerSupervisor.start_child(%{
              login_id: login_id,
              login_hash: hash_string,
              deviceid: deviceid,
              jwt: token
            })

            {:ok, hash_string}
        end
    end
  end

  def login_user(_params) do
    {:error, "invalid parameters"}
  end

  def verify_login_parameters(devicetoken, username, password) do
    Logger.info("verify login params: #{inspect(devicetoken)} #{username} #{password}")

    if String.length(inspect(devicetoken)) > 5 && String.length(username) > 3 &&
         String.length(password) > 3 do
      {:ok}
    else
      {:error, "invalid credentials"}
    end
  end

  defp process_credentials(username, password) do
    case Platform.Accounts.get_user_by_name(username) do
      [user] ->
        Logger.info("user located, processing")

        case process_user(user, password) do
          {:error, reason} -> {:error, reason}
          {:ok, token, hash_string, login_id} -> {:ok, token, hash_string, login_id}
        end

      [] ->
        Logger.warn("User not found")
        {:error, "Not Found User"}
    end
  end

  defp process_user(user, password) do
    Logger.info("username located for login")

    if user.password == password do
      {:ok, token, _claims} = Platform.Guardian.encode_and_sign(user)
      Logger.info("token created")

      hash_string =
        :crypto.hash(:sha256, "#{token}_#{user.name}}")
        |> Base.encode16()

      login_id = UUID.uuid1()
      {:ok, token, hash_string, login_id}
      #
    else
      Logger.warn("invalid credentials")
      {:error, "Invalid credentials"}
      #
    end
  end
end
