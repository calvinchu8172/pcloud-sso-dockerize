class SecondaryConfig
  #include Redis::Objects
  @redis_key = 'secondary_config:portal:index'
  @default_value = {}
  @default_value[:apple_app_id] = '770537600'; # apple app id
  @default_value[:android_app_id] = 'com.zyxel.zCloud'; # android app id
  @default_value[:android_app_argument] = 'http://www.zyxel.com/'; #android app reference website
  @default_value[:android_app_scheme] = 'zyxeldrive://xxx.xxx.xxx'; #android app hook scheme
  @default_value[:android_app_icon] = 'https://lh4.ggpht.com/ aWuemfRx8lvlluW7pY6eNeV_l0_oxTHNX8r8LFfCAKWGlVox3Y4PCevAhReQH7bL0A=w300-rw'; #android smart banner icon

  def self.find id
    puts @default_value[id]
    if  ( @default_value.has_key?(id) == false )
      return ''
    end
    redis_values = Redis::HashKey.new(@redis_key)
    if( redis_values.has_key?(id) == false )
      return @default_value[id]
    end 
    redis_values[id]
  end
end
