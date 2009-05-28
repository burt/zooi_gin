require 'action_controller'

module Gin

  class Builder
    
    attr_reader :data
    
    def initialize(&block)
      raise ArgumentError, "Missing block" unless block_given?
      @data = []
      yield self
    end
    
    def <<(val)
      @data << val
    end
    
    def to_s
      @data.collect(&:to_s).join("\n")
    end
    
    def element(id, key = nil, value = nil)
      @data << Tags::Element.new(id, key, value)
    end
  end
  
  module InstanceMethods
    
    def jquery_ready_script(&block)
      builder = Builder.new(&block).to_s
      ready_tag = Gin::Tags::DomReady.new(builder).to_s
      escaped = ready_tag
      concat javascript_tag(escaped)
    end
    
  end
  
  class TagHelper
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    
  end
  
  module Tags
    
    class Tag
      
      attr_reader :content
      
  		def initialize(*args)
  		  @content = []
  		end

  		def <<(val)
  			@content << val
  		end

  	end

  	class DomReady < Tag
      
      def initialize(content)
        @content = content
      end
      
      def to_s
        "$(function() {\n\t#{content}\n});\n"
      end
      
  	end

  	class Element < Tag
      
      attr_reader :id, :key, :value
      
      def initialize(id, key = nil, value = nil)
        super
        @id, @key, @value = id, key, value
      end
      
      def to_s
        "$('#{@id}').data('#{@key}', #{@value.to_gin});"
      end
      
  	end

  	class ElementData < Element

  	end
    
  end
    
  
=begin
  class Formatter
    
  end
  
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