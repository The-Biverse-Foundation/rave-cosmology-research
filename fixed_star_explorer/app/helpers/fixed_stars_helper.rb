module FixedStarsHelper
  # Despite the name, this actually converts from human-readable strings showing
  # Degrees, Minutes, and Zodiac sign (e.g. 0'0" Aries) to Gate-to-Base Notation.
  def dms_to_g2b(dms)
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

    # Now, calculate decimal degrees
    decimal_degrees = degrees + (minutes / 60)
    decimal_degrees += 58
    decimal_degrees -= 360 if decimal_degrees >= 360

    # Calculate percentage through the 360° circle
    percentage_through = decimal_degrees / 360.0

    # Calculate exact values for Line, Color, Tone, and Base
    exact_line = 384 * percentage_through
    exact_color = 2304 * percentage_through
    exact_tone = 13824 * percentage_through
    exact_base = 69120 * percentage_through

    # Get the Gate from Gates order array
    gates_order = [
      41, 19, 13, 49, 30, 55, 37, 63, 22, 36, 25, 17, 21, 51, 42, 3, 27, 24, 2, 23, 8,
      20, 16, 35, 45, 12, 15, 52, 39, 53, 62, 56, 31, 33, 7, 4, 29, 59, 40, 64, 47, 6,
      46, 18, 48, 57, 32, 50, 28, 44, 1, 43, 14, 34, 9, 5, 26, 11, 10, 58, 38, 54, 61, 60
    ]

    gate = gates_order[(percentage_through * 64).to_i]
    line = (exact_line % 6).to_i + 1
    color = (exact_color % 6).to_i + 1
    tone = (exact_tone % 6).to_i + 1
    base = (exact_base % 5).to_i + 1

    # Full G2B notation (Gate.Line.Color.Tone.Base)
    "#{gate}.#{line}.#{color}.#{tone}.#{base}"
  end

  def dms_to_gate_and_line(dms)
    g2b = dms_to_g2b(dms)
    "Gate " + g2b.split(".").first(2).join(" Line ")
  end

end
