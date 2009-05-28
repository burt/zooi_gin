require 'gin'
require 'extensions'
require 'action_view'
ActionView::Base.send :include, Gin::InstanceMethods
