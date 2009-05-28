

content_for :head do
	jquery_script_ready_tag do
		element :body do
			data :url, new_posts_path(@site)
		end
		# eval the id string using the current post
		# to_gin the result of each
		each_element "##{:id}", posts do |p|
			data :id, p.id
			data :title, p.title
			data :published, p.published
		end
	end
end



class Builder
	
	def initialize(parent)
		@parent = parent
	end
	
	def script_tag(content)
		Script.new(content)
	end
	
	def each_element(id, collection, &block)
		collection.each do |item|
			# parent << 
		end
	end
	
	def data(id, value)
		
	end

end


module Tags
	
	# html
	
	class Tag
		def initialize(content)
			# yield content
			@children = []
		end
		
		def <<(val)
			@children << val
		end
		
		def to_s
			
		end
	end
	
	class Script
		
	end
	
	class DomReady
		
	end
	
	class Element
	
	end
	
	class ElementData
		
	end
	 
	
end


