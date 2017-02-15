# json.user @user
json.id @user.encoded_id
json.email @user.email
json.language @user.language
json.account_token @account_token
json.authentication_token @authentication_token
json.timeout @time_out
json.confirmed @user.confirmed?
json.registered_at @user.created_at.strftime("%F %T")
json.bot_list Settings.xmpp.bots
json.xmpp_ip_addresses Settings.xmpp.nodes
json.stun_ip_addresses Settings.api.stun_ip_addresses
json.xmpp_account @xmpp_account
