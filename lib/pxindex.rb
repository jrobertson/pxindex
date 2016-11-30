#!/usr/bin/env ruby

# file: pxindex.rb

require 'polyrex-headings'


class PxIndex


  def initialize(raw_s)

    s, _ = RXFHelper.read raw_s

    @px = PolyrexHeadings.new(s).to_polyrex   
    @stack = [@px.records]

    @s = ''
    @result = nil

  end

  def q?(s)

    if s.length > @s.length + 1 or s[0..-2] != @s then

      @stack = [@px.records]
      
      s2 = ''
      
      a = s.chars.map do |x|

        s2 += x
        found = search_records(s2, @stack)
        
        break if not found
        found
        
      end
      
      return a ? a.last  : nil
      
    end
        
    i = s.length-1

    records = search_records(s, @stack)

    @s = s
    
    return records

  end

  alias query q?
  

  private

  def search_records(raw_s, stack=@stack)
        
    return @result if raw_s[-1] == ' '
    keywords = raw_s.split(/ /)
    
    s = if keywords.length > 1 then

      r = stack.last.flat_map(&:records)
      stack << r if r.any?
      
      keywords.last
      
    else
      raw_s
    end
    
    a = stack.last.select {|x| x.title[0..s.length-1] == s}
    
    if a.any? then
      
      stack << a
      #@result = a.map(&:title)
      @result = a
      
    else

      r = stack.last.flat_map(&:records)

      if r.any? then
        
        stack << r                
        search_records(s, stack)
        
      else
        
        return nil
        
      end
      
    end

  end

end