class FixedStarsController < ApplicationController
  require "date"

  before_action :load_fixed_stars

  def home
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    # Reference date: February 15, 2025
    reference_date = Date.new(2025, 2, 15)

    # Calculate the difference in days between the provided date and the reference date
    days_difference = (@date - reference_date).to_i

    # Precession rate (in arcseconds per year) is approximately 50.29 arcseconds
    precession_rate = 50.29  # arcseconds per year
    precession_per_day = precession_rate / 365.25  # arcseconds per day

    # Calculate precession shift in arcseconds
    precession_shift = precession_per_day * days_difference

    # Now apply this precession shift to each star's DMS
    @fixed_stars.each do |star|
      star["dms"] = adjust_dms_for_precession(star["dms"], precession_shift)
    end
  end

  def show
    @fixed_star = @fixed_stars.find { |star| star["string_id"] == params[:id] }

    if @fixed_star.nil?
      flash[:alert] = "Star not found."
      redirect_to root_path(date: @date) and return
    end

    @date = params[:date]
  end

  private

  def load_fixed_stars
    @fixed_stars = YAML.load_file(Rails.root.join("config", "fixed_stars.yml"))
  end


  def adjust_dms_for_precession(dms, precession_shift)
    dms_parts = dms.split(" ")
    degrees = dms_parts[0].to_f
    minutes = dms_parts[1].to_f
    zodiac_sign = dms_parts[2]

    # Adjust degrees based on zodiac sign
    case zodiac_sign
    when "Aries"
      degrees += 0
    when "Taurus"
      degrees += 30
    when "Gemini"
      degrees += 60
    when "Cancer"
      degrees += 90
    when "Leo"
      degrees += 120
    when "Virgo"
      degrees += 150
    when "Libra"
      degrees += 180
    when "Scorpio"
      degrees += 210
    when "Sagittarius"
      degrees += 240
    when "Capricorn"
      degrees += 270
    when "Aquarius"
      degrees += 300
    when "Pisces"
      degrees += 330
    else
      raise "Unknown zodiac sign: #{zodiac_sign}"
    end

    # Convert DMS to decimal degrees
    decimal_degrees = degrees + (minutes / 60.0)

    # Apply precession shift (in arcseconds) to the decimal degrees
    decimal_degrees += precession_shift / 3600.0  # Arcseconds to degrees

    # Ensure the degrees wrap around (0-360 degrees)
    decimal_degrees = decimal_degrees % 360

    # Convert back to DMS format
    adjusted_degrees = decimal_degrees.to_i
    adjusted_minutes = ((decimal_degrees - adjusted_degrees) * 60).to_i

    # Rebuild the DMS string
    adjusted_dms = "#{adjusted_degrees % 30}° #{adjusted_minutes}' #{zodiac_sign_for_degrees(adjusted_degrees)}"

    adjusted_dms
  end

  def zodiac_sign_for_degrees(adjusted_degrees)
    case adjusted_degrees.to_i
    when 0..29
      "Aries"
    when 30..59
      "Taurus"
    when 60..89
      "Gemini"
    when 90..119
      "Cancer"
    when 120..149
      "Leo"
    when 150..179
      "Virgo"
    when 180..209
      "Libra"
    when 210..239
      "Scorpio"
    when 240..269
      "Sagittarius"
    when 270..299
      "Capricorn"
    when 300..329
      "Aquarius"
    when 330..359
      "Pisces"
    else
      "Unknown"
    end
  end
end
