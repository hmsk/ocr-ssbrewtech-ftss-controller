Bundler.require(:default)
require 'net/http'

class BrewtechOCRRunner
  def initialize(path = Dir.pwd)
    timestamp = Time.now.strftime('%y%m%d%H%M%S')
    @path_for_captured_image = "#{path}/#{timestamp}_capture.jpg"
    @path_for_cropped_image = "#{path}/#{timestamp}_crop.jpg"

    @config = YAML.load_file("#{Dir.pwd}/config.yml")
  end

  def capture
    camera_conf = @config['camera']
    `raspistill -gs square -o #{@path_for_captured_image} -sh #{camera_conf['sharpness']} -ISO #{camera_conf['iso']} -rot #{camera_conf['rotation']}`

    crop = @config['crop']
    image = MiniMagick::Image.open(@path_for_captured_image)
    image.crop "#{crop['width']}x#{crop['height']}+#{crop['x']}+#{crop['y']}"
    image.write @path_for_cropped_image
  end

  def report_temperature
    temperature = `ssocr --foreground=white --background=black -d -1 #{@path_for_cropped_image} -t #{@config['ocr']['threshold']}`.chomp.gsub('.', '')
    temp_text = temperature.chars.insert(2, '.').join('') + " F"
    puts temp_text
    issue_webhook(temp_text) if @config['webhook'] && temperature.to_i
  end

  def issue_webhook(temp)
    Net::HTTP.post_form(URI(@config['webhook']), message: temp)
  end
end

runner = BrewtechOCRRunner.new
runner.capture
runner.report_temperature
