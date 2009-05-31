require 'gin'
require 'extensions'
require 'action_view'
ActionView::Base.send :include, Gin::InstanceMethods
# ActionView::Template.register_template_handler :gin, Gin::TemplateHandler