namespace :i18n do
  def compare(source, comp, diff={})
    source.each_pair do |key, value|
      comp_value = comp[key]

      if comp[key].nil?
        diff[key] = value
      elsif value.is_a? Hash
        diff[key] = {}
        compare value, comp_value, diff[key]

        diff.delete key if diff[key].blank?
      end
    end

    diff
  end

  def diff_path
    Rails.root.join("config/locales/i18n_diff.yml").to_s
  end

  desc "Generate a diff file between en and fr"
  task :diff, [:from, :to] => :environment do |t, args|
    args.with_defaults(from: "fr", to: "en")

    source_locale = args.from
    source = YAML.load_file(Rails.root.join("config/locales/#{source_locale}.yml"))[source_locale]

    comp_locale = args.to
    comp = YAML.load_file(Rails.root.join("config/locales/#{comp_locale}.yml"))[comp_locale]

    diff = compare source, comp

    diff_file = { comp_locale => diff }

    File.open(diff_path, "w") do |file|
       file.write diff_file.to_yaml
    end
  end

  desc "TODO"
  task :to_dest, [:to] => :environment do |t, args|
    args.with_defaults(to: "en")

    dest_locale = args.to
    dest_path = Rails.root.join("config/locales/#{dest_locale}.yml").to_s

    diff = YAML.load_file(diff_path)
    dest = YAML.load_file(dest_path)

    unified = dest.deep_merge diff

    File.open(dest_path, "w") do |file|
      file.write unified.to_yaml
    end
  end

end
