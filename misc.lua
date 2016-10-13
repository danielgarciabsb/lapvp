function send_message_to_all(message)
  for _, p in pairs(game.players) do
    if p.connected then
      p.print(message)
    end
  end
end

function show_server_info()
  send_message_to_all("Server name: [PVP] Lands of Anarchy")
  send_message_to_all("Discord group: https://discord.gg/h9haBNM")
  send_message_to_all("Steam group: steamcommunity.com/groups/lafactorio")
  send_message_to_all("This game is UNDER DEVELOPMENT. It's not ready yet, but it's playable.")
end
