authmac_path = $LOAD_PATH.find{|i| i =~ /authmac/ }
$LOAD_PATH.unshift(File.expand_path(authmac_path + "/../example"))

require 'app'
run Sinatra::Application
