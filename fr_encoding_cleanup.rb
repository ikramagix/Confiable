# Load the Rails environment
require_relative 'config/environment'

# Custom replacements for problematic encodings
REPLACEMENTS = {
  'Ã©' => 'é',
  'Ã¨' => 'è',
  'Ãª' => 'ê',
  'Ã¢' => 'â',
  'Ã®' => 'î',
  'Ã´' => 'ô',
  'Ã¹' => 'ù',
  'Ã§' => 'ç',
  'Ã€' => 'À',
  'Ã‰' => 'É',
  'Ã»' => 'û',
  'â€™' => "'",
  'â€œ' => '“',
  'â€�' => '”',
  'Â ' => ' ',
  'Ã¼' => 'ü'
}

# Fields to clean
FIELDS_TO_CLEAN = %w[name party position last_name first_name role organization location declaration_link assets additional_info type_duty department cvl]

# Function to clean the text of any bad encodings
def clean_french_encoding(text)
  return text if text.nil?

  cleaned_text = text.dup
  REPLACEMENTS.each do |incorrect, correct|
    cleaned_text.gsub!(incorrect, correct)
  end

  cleaned_text
end

# Loop through each Politician and clean the fields
Politician.find_each do |politician|
  updated = false

  FIELDS_TO_CLEAN.each do |field|
    current_value = politician.send(field)
    next if current_value.nil?

    cleaned_value = clean_french_encoding(current_value)

    if current_value != cleaned_value
      politician.update_column(field, cleaned_value)
      updated = true
    end
  end

  if updated
    puts "Updated Politician ID: #{politician.id}"
  end
end

puts "Cleaning complete."
