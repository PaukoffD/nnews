module ApplicationHelper
  def markdown(text)
    options = {
      space_after_headers: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true,
      no_images:          true, 
      filter_html:        true,
      no_links:           true,
      no_styles:          true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end
