class TvGuideExtractor
  def self.get_html
    @browser = Watir::Browser.new :chrome
    @browser.goto 'http://www.tvguide.com/listings/'
    sleep 2
    channels_ul = @browser.ul(:class => 'listings-grid').html
    @browser.close
    channels_ul
  end
end