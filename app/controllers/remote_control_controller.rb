class RemoteControlController < ApplicationController
  before_filter :set_session_ip
  before_filter :perform_with_handler, :except => [:index, :channel_guide]

  def index
  end

  def take_screenshot
    Dir.glob("#{Rails.root.join('public')}/screenshot*.png"){|path| File.delete(path) }
    @handler.take_screenshot
    render :json => @handler.timestamp
  end

  def trigger_click
    @handler.click_screen(params[:click_x], params[:click_y])
    render :nothing => true
  end

  def trigger_button
    @handler.send_button_click(params[:button])
    render :nothing => true
  end

  def launch_app
    @handler.launch_app(params[:app_name])
    render :nothing => true
  end

  def watch_channel
    if params[:watching] == '1'
      @handler.change_channel(params[:channel])
    else
      @handler.watch_channel(params[:channel])
    end
    render :nothing => true
  end

  def channel_guide
    @guide_html = TvGuideExtractor.get_html
  end

  private

  def set_session_ip
    session[:device_ip] = params[:ip_address] if params[:ip_address].present?
  end

  def perform_with_handler
    @handler = AdbHandler.new(params[:ip_address])
  end

end
