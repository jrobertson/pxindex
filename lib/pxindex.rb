#!/usr/bin/env ruby

# file: pxindex.rb

require 'polyrex-headings'


class PxIndex


  def initialize(raw_s)

    s, _ = RXFHelper.read raw_s

    @px = PolyrexHeadings.new(s).to_polyrex   
    @rs = @px.records

    @s = ''

  end

  def q?(s)

    if (s.length - @s.length).abs > 1 or s[0..-2] != @s then

      @rs = @px.records
      
      s2 = ''
      
      a = s.chars.map do |x|

        s2 += x
        found = search_records(s2, @rs)
        
        break if not found
        found
        
      end
      
      return a ? a.last  : nil
      
    end
        
    i = s.length-1

    records = search_records(s, @rs)

    @s = s
    
    return records

  end

  alias query q?
  

  private

  def search_records(raw_s, rs=@rs)
    
    
    if raw_s[-1] == ' ' then

      child_records = rs.flat_map(&:records)
      
      if child_records.length > 0 then
        @rs = child_records
        return child_records
      else
        return nil
      end
    end

    keywords = raw_s.split(/ /)
    
    s = keywords.length > 1 ? keywords.last : raw_s
    
    a = rs.select {|x| x.title[0..s.length-1] == s}    
    
    if s.length == 1 and a.any? and keywords.length < 2 then
      a = a.first.records
    end
    
    if a.any?  then
      
      @rs = a
      
    else

      return nil unless keywords.length > 1
      
      r = rs.flat_map(&:records)

      if r.any? then
        
        @rs = r                
        search_records(s, rs)
        
      else
        
        return nil
        
      end
      
    end

  end

end