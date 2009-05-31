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
    
    def self.format_key(key)
      key.to_s.camelize(:lower)
    end
    
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
      
      protected
      
      def format_key(key)
        Gin::TagHelper.format_key(key)
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
  
end