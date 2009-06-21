require 'time'
require 'date'
require 'active_support'

# dead_kitten_count += 2
class Object # :nodoc:
  
  def self.gin_attributes(*args)
    define_method :to_gin do
      h = args.to_h { |i| self.send i }
      h.to_gin
    end
  end
  
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
      "#{Gin::TagHelper.format_key(i[0].to_s)}:#{i[1].to_gin}"
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
    "'#{self.to_s}'"
  end
end

class DateTime < Date  # :nodoc:
  def to_gin
    "'#{self.to_s}'"
  end
end

class Date  # :nodoc:
  def to_gin
    "'#{self.to_s}'"
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

module ActiveSupport
  
  class TimeWithZone
    def to_gin
      "'#{self.to_s}'"
    end
  end
  
end