require 'opencv'

class OpenCvUtilities
  include OpenCV
  
  def self.image_coords(template_path, image_path)
    template = IplImage.load(template_path)
    image = IplImage.load(image_path)
    res = template.match_template(image)
    puts res.min_max_loc.inspect
    puts res.min_max_loc[2].to_a.inspect
    (res.min_max_loc[0] / res.min_max_loc[1]) < 0.01 ? res.min_max_loc[2].to_a : nil
    res.min_max_loc[2].to_a
  end
end