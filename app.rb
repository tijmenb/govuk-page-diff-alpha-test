require 'sinatra'
require 'diffy'
require 'nokogiri'

require_relative 'lib/page'

get '/*' do
  base_path = '/' + params['splat'].join
  left = params['left'] || "production"
  right = params['right'] || "production"
  @page = Page.new(base_path, left, right)
  erb :show
end
