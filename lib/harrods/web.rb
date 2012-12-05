module Harrods
  class Web < Sinatra::Base
    include Presenter
    
    set :public_folder, File.expand_path("../../../templates/static", __FILE__)
    set :slim, pretty: true
    
    helpers do
      def present_storage(num)
        present_storage_size(num)
      end
      
      def present_number(num)
        present_with_commas(num)
      end
      
      def present_time(num)
        Time.at(num).to_datetime.to_s
      end
      
      def present_time_iso8601(num)
        Time.at(num).to_datetime.iso8601
      end
    end
    
    get '/' do
      @output, futures, requests = [], {}, RedisClient.client.smembers("averages")
      RedisClient.client.pipelined do
        requests.each do |req|
          futures[req] = RedisClient.client.hgetall(req)
        end
      end
      futures.each do |key, val|
        hash = RedisClient.initialize_hash_from_redis(val.value)
        hash = hash.merge("path" => key)
        @output << hash
      end
      @output = @output.sort_by{|out| -out['latest_hit']}
      slim :index, layout: :layout
    end
    
    
    template :layout do
<<-HTML
doctype 5
html
  head
    title Harrods
    link href="/harrods/css/bootstrap.min.css" rel="stylesheet" media="all"
    link href="/harrods/css/stylesheet.css" rel="stylesheet" media="all"
  body
    .navbar.navbar-fixed-top
      .navbar-inner
        .container
          a.brand Harrods
    .container#main
      .row
        .span12
          == yield
    script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"
    script src="/harrods/js/jquery.timeago.js"
    javascript:
      $(document).ready(function(){
        $('time.timeago').timeago();
      });   
HTML
    end
    
    template :index do
<<-HTML
.action-list
  table.table.table-hover
    thead
      tr
        th Path
        th Objects Created
        th Heap Size
        th Total Hits
        th Last Hit
    tbody
      - @output.each do |output|
        tr
          td== output['path']
          td data-objects=output['objects']
            == present_number output['objects']
          td data-ram=output['ram']
            == present_storage output['ram']
          td== output['iterations']
          td data-timestamp=output['latest_hit']
            time class="timeago" datetime=present_time_iso8601(output['latest_hit'])
              == present_time output['latest_hit']
HTML
    end
      
  end
end