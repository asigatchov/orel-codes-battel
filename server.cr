
require "http/server"
require "json"
require "digest/md5"

server = HTTP::Server.new do |context|
  context.response.headers["Content-Type"] ="text/html; charset=utf-8"
  if context.request.method == "GET"
    res= %q{
      <pre>
      <b>Доступен только POST json запрос</b>

      curl -H "Content-Type: application/json" -X POST } +
      "http://#{context.request.host }:8080/" +
      %q{  \
        -d '{"first_name": "Alexander", "last_name": "Sigatchov", "id": "932j32r"}' -i
    }
    context.response.print res
  else
    context.response.content_type = "application/json"
    body_string = context.request.body.try(&.gets_to_end)
    json =  JSON.parse( body_string.to_s )
    id =  json["id"].to_s
    first_name =  json["first_name"].to_s
    first_name_md5 =  Digest::MD5.hexdigest(first_name)
    last_name =  json["last_name"].to_s
    last_name_md5 =  Digest::MD5.hexdigest(last_name)
    content = {
           "id" => id,
           "first_name" =>  "#{first_name} + #{first_name_md5}",
           "last_name" => "#{last_name} + #{last_name_md5}",
           "current_time" => Time.now.to_s("%F %T %z"),
           "say" => "Crystal is best!!" }.to_json
    context.response.print content
  end
end

address = server.bind_tcp "0.0.0.0", 8080
puts "Listening on http://#{address}"
server.listen
