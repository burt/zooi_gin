require 'action_controller'

module Gin
  
  class TemplateHandler < ActionView::TemplateHandler
    
    def render(template, locals)
      puts ":: #{template.inspect}"
      puts "::: locals"
      #locals.delete!('object')
      locals.each_key do |k|
        puts ":::::: key=#{k}, value=#{locals[k]}"
      end
      source = if template.is_a? ActionView::Base
        template.template.source
      elsif template.is_a? ActionView::ReloadableTemplate
        # ["#{template.name.gsub(')}"].each { |i| locals.delete(i) }
        template.source
      end
      Gin::TagHelper.new.javascript_tag "#{format_locals(locals)}#{source}"
    end
    
    def compilable?
      false
    end
    
    def self.format_key(key)
      key.to_s.camelize(:lower)
    end
    
    private
    
    def escape(content)
      Gin::TagHelper.new.escape_javascript content
    end
    
    def format_locals(locals)
      content = if locals.is_a? Hash
        if locals.has_key?(:collection) && locals[:collection].is_a?(Array)
          locals[:collection].collect(&:to_gin).join("\n\t")
        else
          Gin::Group.new(:body, locals).to_gin
        end
      else
        # todo: raise an error here!
        '/* badly formed */'
      end
      
      doc_ready_script content
    end
    
    def doc_ready_script(content)
      "$(function() {\n\t#{content}\n});\n"
    end
    
  end
  
  class Group
    
    attr_accessor :id, :values
    
    def initialize(id, values)
      @id, @values = id, values
    end
    
    def to_gin
      vals = []
      values.each_pair do |key, value|
        vals << "$('#{@id}').data('#{TemplateHandler.format_key(key)}', #{value.to_gin});"
      end
      vals.join("\n\t")
    end
    
  end
  
  module Record
    
    include ActionController::RecordIdentifier
    
    def self.included(base)
      base.class_eval do 
        def to_gin
          permitted_atts = self.class.instance_variable_get "@gin_attributes"
          atts = {}
          permitted_atts.each { |a| atts[a] = self.send(a) } unless permitted_atts.nil?
          Gin::Group.new("##{dom_id(self)}", atts).to_gin
        end
      end
      base.instance_eval do
        def gin_attributes(*vals)
          @gin_attributes = vals
        end
      end
    end
    
  end
  
  class TagHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
  end
  
end