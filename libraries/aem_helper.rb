module Aem
  module Helper
    def get_jar_opts(jar_opts)
      if jar_opts.any?
        jar_opts_string = '-r'
        jar_opts.each do |jar_opt|
          jar_opts_string << ' ' + jar_opt
        end
        jar_opts_string
      end
    end
  end
end