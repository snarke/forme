#!/usr/bin/env/ruby
require 'rubygems'
require 'erb'
require 'sinatra/base'
require 'models'
require 'forme/sinatra'

class FormeDemo < Sinatra::Base
  disable :run
  disable :session
  enable :static

  helpers Forme::Sinatra::ERB
  helpers do
    attr_reader :form_attr
    attr_reader :subform_opts

    def h(s)
      Rack::Utils.escape_html(s.to_s)
    end

    def form_opts
      return @form_opts if @form_opts
      @form_opts = @form_opts_base || {}
      @form_opts[:one] ||= {}
      @form_opts[:many] ||= {}
      @form_opts[:date] ||= {}
      @form_opts
    end

    def demo(t, opts={})
      @templ = t
      @form_attr = DEMO_MODE ? {:onsubmit=>'return false'} : {:action=>"/#{t.to_s.split('_').first}"}
      erb(t, opts)
    end
  end

  get '/' do
    @page_title = 'Forme Demo Site'
    erb :index
  end

  get '/album/basic/default' do
    @page_title = 'Album Basic - Default'
    @css = "form label { display: block; }"
    demo :album_basic
  end

  get '/album/basic/explicit' do
    @page_title = 'Album Basic - Explicit Labels'
    @form_opts_base = {:labeler=>:explicit, :wrapper=>:div}
    @css = <<-END
label, input, select { display: block; float: left }
label { min-width: 150px; }
form div { padding: 5px; clear: both; }
END
    demo :album_basic
  end

  get '/album/basic/table' do
    @page_title = 'Album Basic - Table'
    @form_opts_base = {:labeler=>:explicit, :wrapper=>:trtd, :inputs_wrapper=>:table}
    demo :album_basic
  end

  get '/album/basic/list' do
    @page_title = 'Album Basic - List'
    @form_opts_base = {:wrapper=>:li, :inputs_wrapper=>:ol}
    @css = "ol, li {list-style-type: none;}"
    demo :album_basic
  end

  get '/album/basic/date' do
    @page_title = 'Album Basic - Date Multiple Select Boxes'
    @form_opts_base = {:date=>{:as=>:select}, :labeler=>:explicit, :wrapper=>:trtd, :inputs_wrapper=>:table}
    demo :album_basic
  end

  get '/album/basic/alt_assoc' do
    @page_title = 'Album Basic - Association Radios/Checkboxes'
    @form_opts_base = {:wrapper=>:li, :inputs_wrapper=>:ol, :many=>{:as=>:checkbox}, :one=>{:as=>:radio}}
    @css = "ol, li {list-style-type: none;}"
    demo :album_basic
  end

  get '/album/basic/readonly' do
    @page_title = 'Album Basic - Read Only'
    @form_opts_base = {:wrapper=>:li, :inputs_wrapper=>:ol, :formatter=>:readonly}
    @css = "ol, li {list-style-type: none;}"
    demo :album_basic
  end

  get '/album/basic/text' do
    @page_title = 'Album Basic - Plain Text'
    @form_opts_base = {:serializer=>:text}
    content_type 'text/plain'
    demo :album_basic, :layout=>false
  end

  get '/album/nested' do
    @page_title = 'Single Level Nesting'
    @css = "form label { display: block; }"
    @subform_opts = {}
    demo :album_nested
  end

  get '/artist/nested' do
    @page_title = 'Multiple Level Nesting'
    @css = "form label { display: block; }"
    @subform_opts = {}
    demo :artist_nested
  end

  get '/album/grid' do
    @page_title = 'Single Level Grid'
    @subform_opts = {:grid=>true}
    demo :album_nested
  end

  get '/artist/grid' do
    @page_title = 'Multiple Level Grid'
    @css = '.integer input, .float input {width: 40px;}'
    @subform_opts = {:grid=>true}
    demo :artist_grid
  end

  unless ENV['DATABASE_URL']
    post '/album' do
      Album.last.update(params[:album])
      redirect back
    end

    post '/artist' do
      Artist.last.update(params[:artist])
      redirect back
    end
  end
end
