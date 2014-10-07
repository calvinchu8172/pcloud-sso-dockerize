module ApplicationHelper
  def breadcrumb(page_flow)
    base_flow = false
    if page_flow.empty?
      base_flow
    else
      base_flow = page_flow.split(",")
    end
  end

  def page_title
    if Rails.env == "staging"
      "-beta"
    end
  end
end
