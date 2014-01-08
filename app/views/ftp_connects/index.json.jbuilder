json.array!(@ftp_connects) do |ftp_connect|
  json.extract! ftp_connect, :id, :server, :username, :password
  json.url ftp_connect_url(ftp_connect, format: :json)
end
