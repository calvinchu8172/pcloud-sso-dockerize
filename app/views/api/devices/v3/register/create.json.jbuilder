json.xmpp_account @device.xmpp_account[:name] + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id
json.xmpp_password @device.xmpp_account[:password]
json.xmpp_bots Settings.xmpp.bots
json.xmpp_ip_addresses Settings.xmpp.nodes
json.stun_ip_addresses Settings.api.stun_ip_addresses