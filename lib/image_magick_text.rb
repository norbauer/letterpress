require 'digest/md5'
require 'pathname'

class ImageMagickText
  @@attributes = :body, :background_color, :font, :fill, :size, :format
  attr_accessor *@@attributes
    
  def initialize(body)
    @body = body
  end
  
  def to_s
    @body.to_s
  end
  
  def render(output_dir)
    if @body.nil?
      raise RuntimeError.new("Text body must be set before rendering the image")
    elsif @format.nil?
      raise RuntimeError.new("Image format must be set before rendering the image")
    end
    
    file_name = generate_filename
    image_path = Pathname.new(File.join(Rails.root, 'public', 'images', output_dir, file_name))
    
    write(image_path) unless image_path.exist?
    
    return File.join(output_dir, file_name)
  end
  
  # ------------------------------ private ------------------------------
  private
  
  def write(image)    
    unless image.parent.exist?
      image.parent.mkpath # like mkdir, but creates intermediate directories
    end
    
    command = 'convert '
    command += %Q( -background "#{@background_color}") unless @background_color.nil?
    command += %Q( -font "#{@font}") unless @font.nil?
    command += %Q( -fill "#{@fill}") unless @fill.nil?
    command += %Q( -pointsize #{@size}) unless @size.nil?
    
    command += %Q( label:"#{@body}")
    command += %Q( "#{image}")

    Rails.logger.debug("Calling ImageMagick with command: #{command}")
    Kernel.system(command)
  end
  
  # Generate a unique filename for this set of text and options.  There 
  # needs to be a different filename for the same set of text but different
  # options, because we will be generating a different file if even just
  # the colors are different.
  def generate_filename
    string = ''
    for attribute in @@attributes
      attr_s = attribute.to_s
      string += attr_s + instance_variable_get("@#{attr_s}").to_s
    end
    
    Digest::MD5.hexdigest(string) + ".#{@format.to_s}"
  end
end
