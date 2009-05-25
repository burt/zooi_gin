require 'time'
require 'date'

class Object
  def to_gin
    "'#'"
  end
end

class String # :nodoc:
  def to_gin
    "'#{Gin::TagHelper.new.escape_javascript self}'"
  end
end

class Array  # :nodoc:
  def to_gin
    "[#{self.collect(&:to_gin).sort.join(', ')}]"
  end
end

class Hash  # :nodoc:
  def to_gin
    contents = ""
    contents = self.to_a.collect do |i|
      "#{Gin::TemplateHandler.format_key(i[0].to_s)}:#{i[1].to_gin}"
    end
    "{#{contents.sort.join(', ')}}"
  end
end

class Numeric  # :nodoc:
  def to_gin
    self
  end
end

class Time  # :nodoc:
  def to_gin
    "'::todo::'"
  end
end

class DateTime < Date  # :nodoc:
  def to_gin
    "'::todo::'"
  end
end

class Date  # :nodoc:
  def to_gin
    "'::todo::'"
  end
end

def true.to_gin  # :nodoc:
  "true"
end

def false.to_gin # :nodoc:
  "false"
end

def nil.to_gin # :nodoc:
  "null"
end