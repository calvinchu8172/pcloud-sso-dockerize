json.user_id @user.encoded_id
json.account_token @user.account_token
json.authentication_token @user.authentication_token
json.timeout @user.authentication_token_ttl
json.confirmed @user.confirmed?
json.registered_at @user.created_at.strftime("%F %T")
json.bot_list Settings.xmpp.bots
json.xmpp_ip_addresses Settings.xmpp.nodes
json.stun_ip_addresses Settings.api.stun_ip_addresses
json.xmpp_account @user.apply_for_xmpp_account