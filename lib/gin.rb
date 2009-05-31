require 'action_controller'

module Gin
  
  module InstanceMethods
    
    def jquery_ready_script(&block)
      Gin::Tags::DomReady.new(self, &block).to_s
    end
    
    def jquery_ready_tag(&block)
      content = jquery_ready_script(&block)
      concat javascript_tag(content)
    end
    
  end
  
  class TagHelper
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    
  end
  
  module Tags
    
    class Tag
      
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
        ".#{@data_type}('#{key}', #{value.to_gin})"
      end
      
	  end
    
  end
    
  
=begin
  
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
  
  module TagHelper
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    
    def jquery_script(&block)
      
      
      javascript_tag jquery_ready_script(&block)
 
    end
    
    def jquery_ready_script(&block)
      
      lambda { block.call(Builder.new(self)) }.call
      #puts s.to_s
      #s + "<<mouse>>"
      # block.call Builder.new(self)
      # s = 
      # capture s.instance_eval(&block)
      # capture &block.call #&(yield Builder.new(self))
      #s = capture block.call(self)
      # s= concat(super(capture(&block), *args), block.binding)
      #s = "'hey'"
      
      #capture (block.call self)
      
      
      #{}"\t$(function() {\n\t\t#{s}\n\t});\n"
    end
    
  end
  
  class Builder
    
    def initialize(helper)
      @helper = helper
    end
    
    def set
      "nice one"
    end
    
  end
  
  class Formatter
    
    def self.format_key(key)
      key.to_s.camelize(:lower)
    end
    
  end
=end


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