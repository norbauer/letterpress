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
    options = options.dup
    options.symbolize_keys!

    letterpress_options = {
      :background_color => options.delete(:background_color),
      :transparent => options.delete(:transparent),
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

    text = ImageMagickText.new(Config.images_dir, letterpress_options)
    text.write_if_necessary

    options = {:alt => letterpress_options[:body], :size => text.size}.merge(options)
    image_tag(text.relative_image_path, options)
  end
end