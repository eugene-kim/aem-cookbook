module Aem
  module Helper
    def get_jar_opts
      jar_opts_runmodes = node[:aem][:author][:jar_opts_runmodes]
      unless jar_opts_runmodes.empty?
        jar_opts_string = '-r' #TODO make sure you aren't adding a duplicate -r for some users
        jar_opts_runmodes.each do |jar_opts_runmode|
          jar_opts_string << ' ' + jar_opts_runmode
        end
        node[:aem][:author][:jar_opts].append jar_opts_string
      else # single jar_opts is being used
        node[:aem][:author][:jar_opts]
      end
    end
  end
end