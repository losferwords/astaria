#!/usr/bin/env ruby
# frozen_string_literal: true

require "webrick"
require "uri"

ROOT = File.expand_path("..", __dir__)
PUBLIC = File.join(ROOT, "_quartz", "public")
PORT = Integer(ENV.fetch("PORT", "8080"))

raise "Quartz public directory is missing; build the site first" unless File.directory?(PUBLIC)

server = WEBrick::HTTPServer.new(
  Port: PORT,
  DocumentRoot: PUBLIC,
  AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)

server.mount_proc "/" do |request, response|
  request_path = URI.decode_www_form_component(request.path).sub(%r{\A/astaria(?=/|\z)}, "")
  relative = request_path.sub(%r{\A/+}, "")
  relative = "index.html" if relative.empty?
  candidates = [
    relative,
    "#{relative}.html",
    File.join(relative, "index.html")
  ]
  path = candidates.map { |candidate| File.expand_path(candidate, PUBLIC) }
    .find { |candidate| candidate.start_with?("#{PUBLIC}/") && File.file?(candidate) }

  unless path
    response.status = 404
    path = File.join(PUBLIC, "404.html")
  end

  response["Content-Type"] = WEBrick::HTTPUtils.mime_type(File.extname(path), WEBrick::HTTPUtils::DefaultMimeTypes)
  response.body = File.binread(path)
end

trap("INT") { server.shutdown }
trap("TERM") { server.shutdown }
puts "Serving bilingual Astaria at http://localhost:#{PORT}"
server.start
