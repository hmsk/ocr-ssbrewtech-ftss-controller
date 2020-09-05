Bundler.require(:default)

class BrewtechOCRRunner
  ISO = '64'
  SHARPNESS = '100'
  ROTATION = '90'

  def initialize(path = Dir.pwd)
    timestamp = Time.now.strftime('%y%m%d%H%M%S')
    @path_for_captured_image = "#{path}/#{timestamp}_capture.jpg"
    @path_for_cropped_image = "#{path}/#{timestamp}_crop.jpg"
  end

  def capture
    `raspistill -gs square -o #{@path_for_captured_image} -sh #{SHARPNESS} -ISO #{ISO} -rot #{ROTATION}`
    image = MiniMagick::Image.open(@path_for_captured_image)
    image.crop '1156x598+425+700'
    image.write @path_for_cropped_image
  end

  def report_temperature
    temperature = `ssocr --foreground=white --background=black -d -1 #{@path_for_cropped_image} -t 80`.chomp
    puts "temp: " + temperature
  end
end

runner = BrewtechOCRRunner.new
runner.capture
runner.report_temperature
