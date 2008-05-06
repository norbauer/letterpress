require 'digest/md5'

module Letterpress
  module Config
    # Directory to look for fonts
    mattr_accessor :fonts_dir
    self.fonts_dir = File.join(Rails.root, 'lib', 'fonts')

    # Directory to output the images, relative to the RAILS_ROOT/public/images directory
    mattr_accessor :images_dir
    self.images_dir = 'letterpress'
    
    # Default file format used to render the image (can be anything ImageMagick supports)
    mattr_accessor :image_format
    self.image_format = 'png'
  end
  
  def letterpress(text, options = {})
    options.symbolize_keys!
        
    letterpress_options = {
      :background_color => options.delete(:background_color),
      :fill => options.delete(:color),
      :size => options.delete(:size),
      :body => text,
      :format => (options.delete(:format) || Config.image_format).to_s
    }
    
    letterpress_options.reject! { |k,v| v.nil? }
    
    if font = options.delete(:font)
      path = File.join(Config.fonts_dir, font)
      if File.exists?(path)
        letterpress_options[:font] = path
      elsif File.exists?(path += '.ttf')
        letterpress_options[:font] = path
      else
        raise ArgumentError.new("Invalid font specified: #{font}")
      end
    end
    
    # Generate a unique filename for this set of text and options.  There 
    # needs to be a different filename for the same set of text but different
    # options, because we will be generating a different file if even just
    # the colors are different.
    file_name = Digest::MD5.hexdigest(letterpress_options.to_s) + ".#{letterpress_options[:format]}"
    output_dir = Config.images_dir
    
    ImageMagickText.new(output_dir, file_name, letterpress_options).write_if_necessary
    
    file_path = File.join(output_dir, file_name)
    options = {:alt => text}.merge(options)
    image_tag(file_path, options)
  end
end 