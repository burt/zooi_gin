require 'action_controller'

module Gin
  
  module Renderer
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    
    # :location => :body, :locals => { :salmon => :mousse }, :collection => @posts
    def javascript_data_tag(options = {})
      javascript_tag "#{format_content(options)}"
    end
    
    private
    
    def format_content(options)
      content = if options.has_key?(:collection) && options[:collection].is_a?(Array)
        options[:collection].collect(&:to_gin).join("\n\t")
      elsif options.has_key?(:locals)
        location = options[:location].nil? ? :body : options[:location]
        Gin::Group.new("#{location}", options[:locals]).to_gin
      else
        '/* raise error here */'
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
        vals << "$('#{@id}').data('#{TagHelper.format_key(key)}', #{value.to_gin});"
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
    
    def self.format_key(key)
      key.to_s.camelize(:lower)
    end
  end
  
=begin
  class TemplateHandler < ActionView::TemplateHandler

    def render(template, locals)
      template = if template.is_a? ActionView::Base
        template.template
      elsif template.is_a? ActionView::ReloadableTemplate
        template
      end

      # remove any unwanted guff
      locals.delete (template.name[1, template.name.size].to_sym)
      locals.delete :object
      @view.javascript_tag "#{format_locals(locals)}#{template.source}"
    end

    def compilable?
      false
    end

  end
=end
  
end