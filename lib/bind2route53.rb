Dir[File.join(File.dirname(__FILE__), 'bind2route53/*.rb')].sort.each { |lib| require lib }
