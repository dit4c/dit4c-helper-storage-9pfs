description = [[
Connects to SSH socket to check latency
]]

author = "Tim Dettrick"

license = "MIT"

categories = {"default"}

portrule = function(host, port)
	return port.protocol == "tcp"
		and port.state == "open"
end

action = function(host, port)
  local owner = ""

  local tls_service = nmap.new_socket()

  local catch = function()
    tls_service:close()
  end

  local try = nmap.new_try(catch)
  local startms = nmap.clock_ms()

  try(tls_service:connect(host.ip, port.number, "tcp"))

	local status, data = tls_service:receive()

  local connectLatency = nmap.clock_ms() - startms
  try(tls_service:close())

  return connectLatency
end
