module ApplicationHelper
  def breadcrumb(page_flow)
    base_flow = false
    if page_flow.empty?
      base_flow
    else
      base_flow = page_flow.split(",")
    end
  end
end
