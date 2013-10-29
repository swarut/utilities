require 'rmagick'



class String
  def extract_file_for(key)
    self.gsub("--#{key.to_s}=", "")
  end

  def android_specific?
    self.match(/_android_/)
  end

  def ios_specific?
    self.match(/_ios_/)
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

def save_for_ios(image, ios_dir, target_file_name)
  target_file_name = target_file_name.gsub("_ios_","_")
  extension = File.extname(target_file_name)
  target_file_name2x =
    "#{File.basename(target_file_name, ".*")}@2x#{extension}"

  # ios
  ios_2x_scaled_image = image.scale(0.666)
  puts "writing #{ios_dir}/#{target_file_name2x}"
  ios_2x_scaled_image.write "#{ios_dir}/#{target_file_name2x}"
  ios_scaled_image = image.scale(0.333)
  puts "writing #{ios_dir}/#{target_file_name}"
  ios_scaled_image.write "#{ios_dir}/#{target_file_name}"
end

def save_for_android(image, android_dir, target_file_name)
  android_xxhdpi = "#{android_dir}/drawable-xxhdpi"
  android_xhdpi = "#{android_dir}/drawable-xhdpi"
  android_hdpi  = "#{android_dir}/drawable-hdpi"
  android_mdpi  = "#{android_dir}/drawable-mdpi"
  android_ldpi  = "#{android_dir}/drawable-ldpi"

  target_file_name = target_file_name.gsub("_android_","_")

  # android
  # mdpi
  android_mdpi_scaled_image = image.scale(0.3)
  puts "writing #{android_mdpi}/#{target_file_name}"
  android_mdpi_scaled_image.write "#{android_mdpi}/#{target_file_name}"

  # ldpi
  android_ldpi_scaled_image = android_mdpi_scaled_image.scale(0.444)
  puts "writing #{android_ldpi}/#{target_file_name}"
  android_ldpi_scaled_image.write "#{android_ldpi}/#{target_file_name}"

  # hdpi
  android_hdpi_scaled_image = image.scale(0.50)
  puts "writing #{android_hdpi}/#{target_file_name}"
  android_hdpi_scaled_image.write "#{android_hdpi}/#{target_file_name}"

  # xhdpi
  android_xhdpi_scaled_image = image.scale(0.75)
  puts "writing #{android_xhdpi}/#{target_file_name}"
  image.write "#{android_xhdpi}/#{target_file_name}"

  # xxhdpi
  puts "writing #{android_xxhdpi}/#{target_file_name}"
  image.write "#{android_xxhdpi}/#{target_file_name}"
end

if ARGV.size == 2
  source, target = extract_argrument(ARGV[0], ARGV[1])
  if File.directory?(source) && File.directory?(target)
    puts "Resizing images:"
    puts "Source: #{source}"
    puts "Target: #{target}"

    source_dir = Dir.new(source)
    ios_dir = "#{target}/ios"
    android_dir = "#{target}/android"

    Dir.mkdir(ios_dir) unless Dir.exist?(ios_dir)
    unless Dir.exist?("#{target}/android")
      Dir.mkdir(android_dir)
      Dir.mkdir("#{android_dir}/drawable-xhdpi")
      Dir.mkdir("#{android_dir}/drawable-hdpi")
      Dir.mkdir("#{android_dir}/drawable-mdpi")
      Dir.mkdir("#{android_dir}/drawable-ldpi")
    end

    ignored_files = %w{. .. .DS_Store android ios}

    (source_dir.to_a - ignored_files).each do |file|

      target_file_name = file
      puts "read " + "#{source}/#{file}"
      image = Magick::Image::read("#{source}/#{file}").first

      if target_file_name.android_specific?
        save_for_android(image, android_dir, target_file_name)
      elsif target_file_name.ios_specific?
        save_for_ios(image, ios_dir, target_file_name)
      else
        save_for_android(image, android_dir, target_file_name)
        save_for_ios(image, ios_dir, target_file_name)
      end

    end
    puts "Done!."

  else
    puts "Please make sure that both source and target are valid folders."
  end
else
  puts "============================================="
  puts "============================================="
  puts "=== Mobile Image Resizer by Warut Surapat"
  puts "=== http://www.swarut.com"
  puts "=== http://www.fingertip.in.th"
  puts "============================================="
  puts "============================================="
  puts "Usage format:"
  puts "ruby mobile_image_resizer.rb --source=[source] --target=[target]"
end

