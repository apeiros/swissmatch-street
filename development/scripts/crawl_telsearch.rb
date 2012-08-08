require 'open-uri'
require 'uri'
require 'nokogiri'
result    = []
begin
 main_url  = "http://map.search.ch/overview/streetlists";
 main_uri  = URI(main_url);
 dom       = Nokogiri.HTML(open(main_url));
 dom.css('td.sl_main_middle h4').each do |canton_node|
   canton_name = canton_node.text
   canton_node.xpath('following-sibling::div[1]/a[@href]').each do |community_node|
     community_name  = community_node.text
     community_uri   = main_uri + community_node['href']
     community_dom   = Nokogiri.HTML(open(community_uri))
     streets         = community_dom.css('td.sl_main_middle a[href]').map(&:text)
     result.concat(streets.map { |street| [canton_name, community_name, street] })
     puts "#{canton_name} - #{community_name} (#{streets.size})"
     sleep(0.2)
   end
 end
 0
end

File.write('data/streets.marshal', Marshal.dump(result), encoding: 'binary')
