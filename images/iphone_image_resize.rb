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

  return [
    matched_source.gsub(/\/$/, ""),
    matched_target.gsub(/\/$/, "")]
end

if ARGV.size == 2
  source, target = extract_argrument(ARGV[0], ARGV[1])
  if File.directory?(source) && File.directory?(target)
    puts "Resizing images:"
    puts "Source: #{source}"
    puts "Target: #{target}"

    source_dir = Dir.new(source)
    # target_dir = Dir.new(target)
    ios_dir = "#{target}/ios"
    android_xhdpi = "#{target}/android/xhdpi"
    android_hdpi  = "#{target}/android/hdpi"
    android_mdpi  = "#{target}/android/mdpi"

    Dir.mkdir(ios_dir) unless Dir.exist?(ios_dir)
    unless Dir.exist?("#{target}/android")
      Dir.mkdir("#{target}/android")
      Dir.mkdir(android_xhdpi)
      Dir.mkdir(android_hdpi)
      Dir.mkdir(android_mdpi)
    end

    ignored_files = %w{. .. .DS_Store android ios}
    puts "--------"
    files = (source_dir.to_a - ignored_files)
    files = files.reject{ |f| File.directory?(f) }
    puts files
    puts "--------"
    (source_dir.to_a - ignored_files).each do |file|

      target_file_name = file
      target_file_name2x = "#{File.basename(file, ".*")}@2x#{File.extname(file)}"
      puts "read " + "#{source}/#{file}"
      image = Magick::Image::read("#{source}/#{file}").first

      # ios
      ios_2x_scaled_image = image.scale(0.888)
      puts "writing #{ios_dir}/#{target_file_name2x}"
      ios_2x_scaled_image.write "#{ios_dir}/#{target_file_name2x}"
      ios_scaled_image = image.scale(0.444)
      puts "writing #{ios_dir}/#{target_file_name}"
      ios_scaled_image.write "#{ios_dir}/#{target_file_name}"

      # android
      android_mdpi_scaled_image = image.scale(0.444)
      puts "writing #{android_mdpi}/#{target_file_name}"
      android_mdpi_scaled_image.write "#{android_mdpi}/#{target_file_name}"
      android_hdpi_scaled_image = image.scale(0.6666)
      puts "writing #{android_hdpi}/#{target_file_name}"
      android_hdpi_scaled_image.write "#{android_hdpi}/#{target_file_name}"
      puts "writing #{android_xhdpi}/#{target_file_name}"
      image.write "#{android_xhdpi}/#{target_file_name}"
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

