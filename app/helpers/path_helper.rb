module PathHelper

  def current_path?(controller, actions = [])
    if controller.to_s == controller_name
      if actions.blank?
        true
      else
        actions = actions.map(&:to_s)
        if action_name.in? actions
          true
        else
          false
        end
      end
    else
      false
    end
  end
end