require 'sinatra'
require 'diffy'
require 'nokogiri'

class Page
  attr_reader :base_path, :env_left, :env_right

  def initialize(base_path, env_left, env_right)
    @base_path = base_path
    @env_left = env_left
    @env_right = env_right
  end

  def diff_html
    left_html = fetch_html(left_url)
    right_html = fetch_html(right_url)
    Diffy::Diff.new(left_html, right_html, context: 3).to_s(:html)
  end

  def url_for(env)
    {
      "production" => "https://www-origin.publishing.service.gov.uk#{base_path}",
      "staging" => "https://www-origin.staging.publishing.service.gov.uk#{base_path}",
      "preview" => "https://betademo:nottobeshared@www-origin.preview.alphagov.co.uk#{base_path}",
    }.fetch(env)
  end

  def left_url
    url_for(env_left)
  end

  def right_url
    url_for(env_right)
  end

private

  FILTERS = [
    'assets.digital.cabinet-office.gov.uk',
  ]

  def fetch_html(uri)
    html = Nokogiri::HTML(`curl -s #{uri}`).css('body').to_s
    FILTERS.each do |pattern|
      html.gsub!(pattern, '')
    end
    html
  end
end

get '/*' do
  base_path = '/' + params['splat'].join
  left = params['left'] || "production"
  right = params['right'] || "staging"
  @page = Page.new(base_path, left, right)
  erb :show
end
