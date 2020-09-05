class BrewtechOCRRunner
  ISO = '64'
  SHARPNESS = '100'
  ROTATION = '90'

  def initialize(path = Dir.pwd)
    @path_for_captured_image = "#{path}/#{Time.now.strftime('%y%m%d')}_capture.jpg"
  end

  def capture
    `raspistill -gs square -o #{@path_for_captured_image} -sh #{SHARPNESS} -ISO #{ISO} -rot #{ROTATION}`
  end

  def report_temperature
    temperature = `ssocr --foreground=white --background=black -d -1 #{@path_for_captured_image} -t 80`
  end
end

runner = BrewtechOCRRunner.new
runner.capture
runner.report_temperature
