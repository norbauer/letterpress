require 'pathname'

class ImageMagickText
  def initialize(output_dir, options)
    # Generate a unique filename for this set of text and options.  There 
    # needs to be a different filename for the same set of text but different
    # options, because we will be generating a different file if even just
    # the colors are different.
    @file_name = Digest::MD5.hexdigest(options.to_s) + ".#{options[:format]}"

    @output_dir = output_dir
    @absolute_image_path = Pathname.new(File.join(Rails.root, 'public', 'images', @output_dir, @file_name))
    @options = options
  end

  def size
    return @size
  end

  def size=(str)
    @size = str
  end

  def write_if_necessary
    write if !@absolute_image_path.exist? || Rails.env == 'development'
  end
  
  def relative_image_path
    File.join(@output_dir, @file_name)
  end

  # ------------------------------ private ------------------------------
  private

  def write
    unless @absolute_image_path.parent.exist?
      @absolute_image_path.parent.mkpath # like mkdir, but creates intermediate directories
    end
    
    command = generate_convert_command

    Rails.logger.debug("Calling ImageMagick with command: #{command}")
    self.size = %x(#{command}).scan(/\d+x\d+/).first
  end

  def generate_convert_command
    command = 'convert -verbose'
    command += %Q( -background "#{@options[:background_color]}") if @options[:background_color]
    command += %Q( -font "#{@options[:font]}") if @options[:font]
    command += %Q( -transparent "#{@options[:transparent]}") if @options[:transparent]
    command += %Q( -fill "#{@options[:fill]}") if @options[:fill]
    command += %Q( -pointsize #{@options[:size]}) if @options[:size]
    command += %Q( -density #{@options[:density]}) if @options[:density]    
    command += %Q( label:"#{@options[:body]}")
    command += %Q( "#{@absolute_image_path}")
  end
end
