if Rails.env.development?
  # 預設的 prompt_name 是 pry，下面這行會把 prompt_name 變成該 project 的名稱 (自動抓)
  Pry.config.prompt_name = Rails.application.class.parent_name.underscore.dasherize

  old_prompt = Pry.config.prompt

  env = "\001\e[0;33m\002#{Rails.env.upcase}\001\e[0m\002" # 黃色 的 env 名稱

  # 替換 pry prompt 的方法在 https://github.com/pry/pry/wiki/Customization-and-configuration#Config_prompt 有教學
  Pry.config.prompt = [
    proc { |*a| "#{env} #{old_prompt.first.call(*a)}"  },
    proc { |*a| "#{env} #{old_prompt.second.call(*a)}" }
  ]
end
