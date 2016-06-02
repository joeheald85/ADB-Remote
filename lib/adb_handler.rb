require 'opencv'

class AdbHandler
  include OpenCV

  attr_accessor :timestamp

  def initialize(ip_address="192.168.0.14")
    @ip_address = ip_address
    reset_adb_client
    connect_adb
    @timestamp = Time.now.to_f.to_s.sub('.', '')
  end

  def reset_adb_client
    `#{adb_path} kill-server`
    `#{adb_path} start-server`
  end

  def connect_adb
    `#{adb_path} connect #{@ip_address}`
  end

  def take_screenshot
    `#{adb_path} shell screencap -p | perl -pe 's/\\x0D\\x0A/\\x0A/g' > #{Rails.root}/public/screenshot#{@timestamp}.png`
  end

  def click_screen(x, y)
    `#{adb_path} shell input tap #{x} #{y}`
  end

  def send_button_click(button)
    `#{adb_path} shell input keyevent #{self.class.button_codes[button]}`
  end

  def input_text(content)
    `#{adb_path} shell input text "#{content.gsub(' ', '%20')}"`
  end

  def swipe(x1,y1,x2,y2,duration=100)
    `#{adb_path} shell input swipe #{x1} #{y1} #{x2} #{y2} #{duration}`
  end

  def self.disconnect_adb(ip_address)
    `#{adb_path} disconnect #{ip_address}`
  end

  def launch_app(app_name)
    `#{adb_path} shell monkey -p #{self.class.app_list[app_name]} -c android.intent.category.LAUNCHER 1`
  end

  def kill_app(app_name)
    `#{adb_path} shell am kill #{self.class.app_list[app_name]}`
  end

  def send_batch_script(batch_string)
    File.open(Rails.root.join("tmp/tmp_batch_file.bat"), 'w'){|f| f.write(batch_string) }
    `#{adb_path} shell < #{Rails.root.join("tmp/tmp_batch_file.bat").to_s}`
  end

  def watch_channel(channel)
    sleep(1)
    send_button_click('CENTER')
    click_screen(22,364)
    sleep(2)
    d,l,r = self.class.watch_channel_event_values[channel.downcase]
    batch_script = ""
    d.times{ batch_script += "sendevent /dev/input/event3 0004 0004 00070051\nsendevent /dev/input/event3 1 108 1\nsendevent /dev/input/event3 0 0 0\nsendevent /dev/input/event3 0004 0004 00070051\nsendevent /dev/input/event3 1 108 0\nsendevent /dev/input/event3 0 0 0\n" }
    l.times{ batch_script += "input keyevent #{self.class.button_codes["LEFT"]}\n" }
    r.times{ batch_script += "input keyevent #{self.class.button_codes["RIGHT"]}\n" }
    batch_script += "input keyevent #{self.class.button_codes["CENTER"]}\nexit\n"
    send_batch_script(batch_script)
  end

  def change_channel(channel)
    3.times{ click_screen(1400,3) }
    sleep(2)
    batch_script = ""
    self.class.change_channel_counts[channel.downcase].times{ batch_script += "sendevent /dev/input/event3 0004 0004 00070051\nsendevent /dev/input/event3 1 108 1\nsendevent /dev/input/event3 0 0 0\nsendevent /dev/input/event3 0004 0004 00070051\nsendevent /dev/input/event3 1 108 0\nsendevent /dev/input/event3 0 0 0\n" }
    batch_script += "input keyevent #{self.class.button_codes["CENTER"]}\nexit\n"
    send_batch_script(batch_script)
  end

  def adb_path
    Rails.root.join('bin/adb')
  end

  def self.button_codes
    @adb_button_codes ||= YAML.load(File.read(Rails.root.join('config/adb_button_codes.yml')))
  end

  def self.watch_channel_event_values
    @watch_channel_values ||= YAML.load(File.read(Rails.root.join('config/xfinity_watch_channel_sequence.yml')))
  end

  def self.change_channel_counts
    @change_channel_values ||= YAML.load(File.read(Rails.root.join('config/xfinity_channel_order.yml')))
  end

  def self.app_list
    {
      'Xfinity TV Go' => 'com.xfinity.playnow'
    }
  end

end