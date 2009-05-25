require 'gin'
require 'extensions'
require 'action_view'
require 'active_record'
ActiveRecord::Base.send :include, Gin::Record
ActionView::Template.register_template_handler :gin, Gin::TemplateHandler
