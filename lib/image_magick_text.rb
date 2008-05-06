require 'pathname'

class ImageMagickText
  def initialize(output_dir, file_name, options)
    @absolute_image_path = Pathname.new(File.join(Rails.root, 'public', 'images', output_dir, file_name))
    @options = options
  end
  
  def write_if_necessary
    write if !@absolute_image_path.exist? || Rails.env == 'development'
  end
  
  # ------------------------------ private ------------------------------
  private
  
  def write
    unless @absolute_image_path.parent.exist?
      @absolute_image_path.parent.mkpath # like mkdir, but creates intermediate directories
    end
    
    command = generate_convert_command

    Rails.logger.debug("Calling ImageMagick with command: #{command}")
    Kernel.system(command)
  end
  
  def generate_convert_command
    command = 'convert '
    command += %Q( -background "#{@options[:background_color]}") if @options[:background_color]
    command += %Q( -font "#{@options[:font]}") if @options[:font]
    command += %Q( -fill "#{@options[:fill]}") if @options[:fill]
    command += %Q( -pointsize #{@options[:size]}) if @options[:size]
    
    command += %Q( label:"#{@options[:body]}")
    command += %Q( "#{@absolute_image_path}")
  end
end
