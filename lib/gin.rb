require 'action_controller'

module Gin
  
  class TagHelper
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    
    def self.format_key(key)
      key.to_s.camelize(:lower)
    end
    
    module Formatter
      
      def format_key(key)
        Gin::TagHelper.format_key(key)
      end
      
      def format_locals(locals = {})
        vars_string = ""
        locals.each_pair do |key, value|
          vars_string << "var #{format_key(key)} = #{value.to_gin};\n"
        end
        vars_string
      end
      
    end
    
  end
  
  module InstanceMethods
    include Gin::TagHelper::Formatter
    
    def jquery_ready_script(&block)
      Gin::Tags::DomReady.new(self, &block).to_s
    end
    
    def jquery_ready_tag(&block)
      content = jquery_ready_script(&block)
      concat javascript_tag(content)
    end
    
    def jquery_locals(locals ={})
      format_locals locals
    end
    
  end
  
  module Tags
    
    class Tag
      include Gin::TagHelper::Formatter
      
      attr_reader :parent, :content
      
  		def initialize(parent, &block)
  		  @parent = parent
  		  @content = []
  		  yield self if block_given?
  		end

  		def <<(val)
  			@content << val
  		end
      
  	end

  	class DomReady < Tag
      
      def initialize(parent, &block)
        super parent, &block
      end
      
      def element(id, &block)
        self << Element.new(self, id, &block)
      end
      
      def to_s
        formatted = content.collect(&:to_s).join("\n\t")
        "$(function() {\n\t#{formatted}\n});\n"
      end
      
  	end

  	class Element < Tag
      
      attr_reader :id
      
      def initialize(parent, id, &block)
        super parent, &block
        @id = id
      end
      
      def data(key, value)
        self << Data.new(self, "data", key, value)
      end
      
      def attr(key, value)
        self << Data.new(self, "attr", key, value)
      end
      
      def to_s
        @content.collect do |c|
          "$('#{@id}')#{c};"
        end.join("\n\t")
      end
      
  	end
  	
  	class Data < Tag
  	  
  	  attr_reader :key, :value
  	  
  	  def initialize(parent, data_type, key, value, &block)
        super parent, &block
        @data_type, @key, @value = data_type, key, value
      end
      
      def to_s
        ".#{@data_type}('#{format_key(key)}', #{value.to_gin})"
      end
      
	  end
    
  end

=begin
  class TemplateHandler < ActionView::TemplateHandler

    def render(template, locals)
      # @view.controller.headers["Content-Type"] = 'text/javascript; charset=utf-8'
      
      template = if template.is_a? ActionView::Base
        template.template
      elsif template.is_a? ActionView::ReloadableTemplate
        template
      end

      # remove any unwanted guff
      locals.delete (template.name[1, template.name.size].to_sym)
      locals.delete :object
      "#{format_locals(locals)}\n#{template.source}"
    end
      
    def compilable?
      false
    end
    
    private
    
    def format_locals(locals)
      vars_string = ""
      locals.each_pair do |key, value|
        vars_string << "var #{format_key(key)} = #{value.to_gin};\n"
      end
      vars_string
    end
    
    def format_key(key)
      Gin::TagHelper.format_key(key)
    end

  end
=end
  
end