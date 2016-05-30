class TvGuideExtractor
  def self.get_html
    html_data = open('http://www.tvguide.com/listings/').read
    nokogiri_object = Nokogiri::HTML(html_data)
  end
end