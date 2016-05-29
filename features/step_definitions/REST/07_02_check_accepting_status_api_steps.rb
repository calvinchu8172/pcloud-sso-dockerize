When(/^user sends a GET request to \/resource\/(\d+)\/permission with:$/) do |arg1, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/permission"

  if data["certificate_serial"].nil?
    certificate_serial = nil
  elsif data["certificate_serial"].include?("INVALID")
    certificate_serial = "invalid certificate_serial"
  else
    certificate_serial = @certificate.serial
  end

  if data["cloud_id"].include?("INVALID")
    @invitee_cloud_id = "invalid cloud_id"
  elsif data["cloud_id"].include?("VALID USER")
    @invitee_cloud_id = @cloud_id
  else
    @invitee_cloud_id
  end

  if data["invitation_key"].include?("INVALID")
    @invitation_key = "invalid invitation_key"
  else
    @invitation_key
  end

  if data["signature"].nil?
    signature = nil
  elsif data["signature"].include?("INVALID")
    signature = "invalid signature"
  else
    signature = create_signature(certificate_serial, @invitee_cloud_id, @invitation_key)
  end

  get path, {
    cloud_id: @invitee_cloud_id,
    invitation_key: @invitation_key,
    certificate_serial: certificate_serial,
    signature: signature
    }

end

When(/^the acception succeeds$/) do
  allow_any_instance_of(Api::Resource::PermissionsController).to receive(:done?).and_return(true)
end

When(/^something wrong with some error$/) do
  allow_any_instance_of(AcceptedUser).to receive(:finish_accept).and_raise(Exception)
end

When(/^the device returns an error code (\d+)$/) do |arg1|
  allow_any_instance_of(Api::Resource::PermissionsController).to receive(:error_code).and_return('571')
end

When(/^timeout$/) do
  @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @invitee.id)
  @redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  key = "invitation:#{@accepted_user.id}:session"
  # session = @redis.hgetall(key)
  time = Time.now.to_i - 10
  @redis.hset(key, 'expire_at', time)
end

