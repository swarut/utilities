require 'rmagick'

class String
  def extract_file_for(key)
    self.gsub("--#{key.to_s}=", "")
  end
end

def extract_argrument(args0, args1)
  matched_source = args0.match(/--source=/) ?
    args0.extract_file_for(:source) :
    args1.extract_file_for(:source)
  matched_target = args0.match(/--target=/) ?
    args0.extract_file_for(:target) :
    args1.extract_file_for(:target)
  return [matched_source, matched_target]
end

if ARGV.size == 2
  source, target = extract_argrument(ARGV[0], ARGV[1])
  if File.directory?(source) && File.directory?(target)
    puts "Resizing images:"
    puts "Source: #{source}"
    puts "Target: #{target}"

    source_dir = Dir.new(source)
    target_dir = Dir.new(target)

    source_dir.each do |file|
      if file != "." && file != ".." && file != ".DS_Store"
        target_file_name = file.gsub(/@2x/, "")
        image = Magick::Image::read("#{source}/#{file}").first
        scaled_image = image.scale(0.5)
        scaled_image.write "#{target}/#{target_file_name}"
        puts "successfully save #{target}/#{target_file_name}"
      end
    end
    puts "Done!."
  else
    puts "Please make sure that both source and target are valid folders."
  end
else
  puts "============================================="
  puts "============================================="
  puts "=== Iphone Image Resizer by Warut Surapat"
  puts "=== http://www.swarut.com"
  puts "=== http://www.fingertip.in.th"
  puts "============================================="
  puts "============================================="
  puts "Usage format:"
  puts "ruby iphone_image_resize.rb --source=[source] --target=[target]"
end

