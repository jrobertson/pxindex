#!/usr/bin/env ruby

# file: pxindex.rb

require 'polyrex-headings'


class PxIndex

  def initialize(raw_s, debug: false)

    s, _ = RXFHelper.read raw_s
    
    lines = s.lines

    header = []
    header << lines.shift until lines[0].strip.empty?
    
    a = LineTree.new(lines.join.gsub(/^# [a-z]\n/,'')).to_a
    a2 = a.group_by {|x| x.first[0] }.to_a
    
    s2 =  a2.map {|x| '# ' + x[0] + "\n\n" + treeize(x[-1]) }.join("\n\n")

    @raw_px = header.join + "\n" + s2

    @px = PolyrexHeadings.new(@raw_px).to_polyrex   
    @rs = @px.records

    @s = ''
    @a = []
    @debug = debug

  end
  
  def parent()
    @rs.first
  end

  def q?(s)
    
    return @a.last if s == @s
    puts '@s : ' + @s.inspect if @debug
    puts 's: ' + s.inspect if @debug
    
    # @s is used to store the previous string input to compare it with 
    # the new string input
    
    if (s.length - @s.length).abs >= 1 or s[0..-2] != @s then
      
      @s = s      

      @rs = @px.records
      
      s2 = ''
      
      @a = s.chars.map do |x|

        s2 += x
        found = search_records(s2, @rs)
        
        break if not found
        found
        
      end

      return @a ? @a.last  : nil
      
    end
  
    return []
  
  end

  alias query q?
  
  def to_s()
    @raw_px
  end

  private

  def search_records(raw_s, rs=@rs)
    
    puts 'raw_s : ' + raw_s.inspect if @debug
    
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
    
    if @debug then
      puts 'a: ' + a.inspect 
      if a.any? then
        puts 'a.map ' + a.map(&:title).inspect
      end
    end
    
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
  
  def treeize(obj, indent=-2)

    if obj.is_a? Array then

      obj.map {|x| treeize(x, indent+1)}.join("\n")

    else

      '  ' * indent + obj

    end
  end  

end
