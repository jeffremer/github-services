class Service::Freckle < Service
  self.hook_name = :freckle

  def receive_push
    entries, subdomain, token, project =
      [], data['subdomain'].strip, data['token'].strip, data['project'].strip

    payload['commits'].each do |commit|
      minutes = (commit["message"].split(/\s/).find { |item| /^f:/ =~ item } || '')[2,100]
      next unless minutes
      entries << {
        :date => commit["timestamp"],
        :minutes => minutes,
        :description => commit["message"].gsub(/(\s|^)f:.*(\s|$)/, '').strip,
        :url => commit['url'],
        :project_name => project,
        :user => commit['author']['email']
      }
    end

    http.headers['Content-Type'] = 'application/json'
    http_post "http://#{data['subdomain']}.letsfreckle.com/api/entries/import",
      {:entries => entries, :token => data['token']}.to_json
  end
end
