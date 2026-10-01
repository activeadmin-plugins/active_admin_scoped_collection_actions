require 'spec_helper'

# en, de, es and sv gained confirm_submit_summary, confirm_destroy_summary and
# confirm_action_summary together. This is the cheap guard against the next key
# landing in en.yml only.
describe 'locale files' do

  def leaf_keys(value, prefix = nil)
    return [prefix] unless value.is_a?(Hash)

    value.flat_map { |key, nested| leaf_keys(nested, [prefix, key].compact.join('.')) }
  end

  let(:keys_per_locale) do
    Dir[File.expand_path('../../config/locales/*.yml', __FILE__)].sort.to_h do |path|
      translations = YAML.load_file(path).values.first
                         .fetch('active_admin_scoped_collection_actions')
      [File.basename(path, '.yml'), leaf_keys(translations).sort]
    end
  end

  # Without this the parity example below would pass on an empty glob.
  it 'are there for every supported language' do
    expect(keys_per_locale.keys).to match_array(%w[de en es sv])
  end

  it 'expose the same keys in every language' do
    reference = keys_per_locale.fetch('en')

    keys_per_locale.each do |locale, keys|
      expect(keys).to eq(reference),
                      "#{locale}.yml: missing #{reference - keys}, unexpected #{keys - reference}"
    end
  end
end
