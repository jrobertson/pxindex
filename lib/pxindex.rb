#!/usr/bin/env ruby

# file: pxindex.rb

require 'nokogiri'
require 'pxindex-builder'
require 'polyrex-headings'



class PxIndex

  def initialize(raw_s=nil, debug: false, allsorted: false, indexsorted: false)

    @allsorted, @indexsorted = allsorted, indexsorted
    @debug = debug    
    
    read raw_s if raw_s

  end

  # Returns a PxIndexBuilder object which can build from am index or phrases
  #
  def import(s)
    
    read(PxIndexBuilder.new(s, debug: @debug).to_s)
    
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

      @rs = @px.records.flat_map(&:records)
      
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
  
  def build_html()
    
    @px.each_recursive do |x, parent|
      
      if x.is_a? Entry then
        
        trail = parent.attributes[:trail]
        s = x.title.gsub(/ +/,'-')
        x.attributes[:trail] = trail.nil? ? s : trail + '/' + s
        
      end
      
    end

    doc  = Nokogiri::XML(@px.to_xml)
    xsl  = Nokogiri::XSLT(xslt())

    html_doc = Rexle.new(xsl.transform(doc).to_s)
        
    html_doc.root.css('.atopic').each do |e|      
      
      puts 'e: ' + e.parent.parent.xml.inspect if @debug
      
      href = e.attributes[:href]
      if href.empty? or href[0] == '!' then
        
        if block_given? then
          
          yield(e)
          
        else
          
          e.attributes[:href] = '#' + e.attributes[:trail].split('/')\
              .last.downcase
          
        end
      end
    end
    
    html_doc.xml(pretty: true, declaration: false)
    
  end
  
  def to_px()
    @px
  end
  
  def to_s()
    @raw_px
  end

  private
  
  def read(raw_s)
    
    s, _ = RXFHelper.read raw_s
    
    lines = s.lines

    header = []
    header << lines.shift until lines[0].strip.empty?
    
    a = LineTree.new(lines.join.gsub(/^# [a-z]\n/,'')).to_a
    a2 = a.group_by {|x| x.first[0] }.sort.to_a
    
    s2 =  a2.map do |x|      
      '# ' + x[0] + "\n\n" + \
          treeize(@allsorted || @indexsorted ? sort(x[-1]) : x[-1])
    end.join("\n\n")
    
    puts 's2: ' + s2.inspect if @debug
    @raw_px = header.join + "\n" + s2

    @px = PolyrexHeadings.new(@raw_px).to_polyrex   
    @rs = @px.records.flat_map()

    @s = ''
    @a = []    
  end

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
    
    if a.any?  then
      
      @rs = a
      
    else

      return nil unless keywords.length > 1
      
      r = rs

      if r.any? then
        
        @rs = r                
        search_records(s, rs)
        
      else
        
        return nil
        
      end
      
    end

  end
  
  def sort(a)
    
    puts 'sorting ... a: ' + a.inspect if @debug
    return sort_children(a) if a.first.is_a? String
    
    r = a.sort_by do |x| 
      next unless x[0].is_a? String
      x[0]
    end
    
    puts 'after sort: ' + r.inspect if @debug
    
    r
    
  end
  
  def sort_children(a)
    [a[0]] + a[1..-1].sort_by {|x| x[0]}
  end
  
  def treeize(obj, indent=-2)

    if obj.is_a? Array then
      
      r = (@allsorted ? sort(obj) : obj).map {|x| treeize(x, indent+1)}.join("\n")
      puts 'r: ' + r.inspect if @debug
      r

    else

      '  ' * indent + obj

    end
  end

  
  def xslt()
<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />

<xsl:template match='entries'>
  <ul>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>
  </ul>
</xsl:template>

<xsl:template match='entries/summary'>
</xsl:template>

<xsl:template match='records/section'>
  <li><h1><xsl:value-of select="summary/heading"/></h1><xsl:text>
      </xsl:text>

    <xsl:apply-templates select='records'/>

<xsl:text>
    </xsl:text>
  </li>
</xsl:template>


<xsl:template match='records/entry'>
    <ul id="{summary/title}">
  <li><xsl:text>
          </xsl:text>
          <a href="{summary/url}" class='atopic' id='{@id}' trail='{@trail}'>
          <xsl:value-of select="summary/title"/></a><xsl:text>
          </xsl:text>

    <xsl:apply-templates select='records'/>

<xsl:text>
        </xsl:text>
  </li>
    </ul>
</xsl:template>


</xsl:stylesheet>    
EOF
  end  

end
