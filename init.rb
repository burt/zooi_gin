require 'gin'
require 'gin_extensions'
require 'action_view'
ActionView::Base.send :include, Gin::InstanceMethods