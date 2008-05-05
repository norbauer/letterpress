if Rails.env == 'development'
  load 'image_magick_text.rb'
else
  require 'image_magick_text'
end

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
        
    text = ImageMagickText.new(text)
        
    if font = options.delete(:font)
      paths = [ File.join(Config.fonts_dir, font),
                File.join(Config.fonts_dir, font + '.ttf') ]
      unless path = paths.find { |path| File.exists?(path) }
        raise ArgumentError.new("Invalid font specified: #{font}")
      end
      text.font = path
    end
    
    if color = options.delete(:color)
      text.fill = color
    end
    
    if background_color = options.delete(:background_color)
      text.background_color = background_color
    end
    
    if size = options.delete(:size)
      text.size = size
    end
    
    text.format = options.delete(:format) || Config.image_format
    
    file_name = text.render(Config.images_dir)
    options = {:alt => text}.merge(options)
    
    image_tag(file_name, options)
  end
end 