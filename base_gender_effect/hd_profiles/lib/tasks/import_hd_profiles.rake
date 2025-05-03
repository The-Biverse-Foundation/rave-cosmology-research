namespace :hd do
  desc "Import Human Design Profiles from AstroDatabank XML (AA-rated only)"
  task import: :environment do
    require 'nokogiri'
    require 'swe4r'

    def convert_to_decimal(coord)
      return nil unless coord
      sign = coord[-1]
      degrees = coord[0..-2].to_f
      sign.downcase == 's' || sign.downcase == 'w' ? -degrees : degrees
    end

    puts "Clearing existing HumanDesignProfile records..."
    HumanDesignProfile.delete_all

    file = File.read('c_sample.xml')
    doc = Nokogiri::XML(file)

    doc.xpath('//adb_entry').each do |entry|
      # Only keep entries with Rodden rating "AA"
      rodden = entry.at_xpath('./public_data/roddenrating')&.text&.strip
      next unless rodden == 'AA'
      
      gender = entry.at_xpath('./public_data/gender')&.text&.strip
      bdate_node = entry.at_xpath('./public_data/bdata/sbdate')
      btime_node = entry.at_xpath('./public_data/bdata/sbtime')
      place_node = entry.at_xpath('./public_data/bdata/place')

      next unless bdate_node && btime_node

      begin
        year = bdate_node['iyear'].to_i
        month = bdate_node['imonth'].to_i
        day = bdate_node['iday'].to_i
        hour, minute = btime_node.text.strip.split(':').map(&:to_i)

        long = convert_to_decimal(place_node&.[]('slong')) || 0.0
        lat  = convert_to_decimal(place_node&.[]('slati')) || 0.0

        jd_ut = Swe4r::swe_julday(year, month, day, hour + minute / 60.0)

        sun_long = Swe4r::swe_calc_ut(jd_ut, Swe4r::SE_SUN, Swe4r::SEFLG_SWIEPH)[0]

        # Sun Gate and Line
        gate_size = 360.0 / 64
        sun_gate = (sun_long / gate_size).floor + 1
        degrees_into_gate = sun_long % gate_size
        sun_line = (degrees_into_gate / (gate_size / 6)).floor + 1

        # Base calculation: 5 bases per line
        line_offset = degrees_into_gate % (gate_size / 6)
        base = (line_offset / ((gate_size / 6) / 5)).floor + 1

        HumanDesignProfile.create!(gender: gender, base: base)
        puts "Saved #{gender} with Base #{base}"

      rescue => e
        puts "Error: #{e.message}"
      end
    end
  end
end
