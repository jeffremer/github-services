class Service::Campfire < Service
  self.hook_name = :campfire

  def receive_push
    raise_config_error 'Missing campfire token' if data['token'].to_s.empty?

    messages = []
    messages << "#{summary_message}: #{summary_url}"
    messages += commit_messages.first(4)

    if messages.first =~ /pushed 1 new commit/
      messages.shift # drop summary message
      messages.first << " (#{distinct_commits.first['url']})"
    end

    begin
      play_sound = data['play_sound'].to_i == 1

      if !campfire.login(data['token'], 'X')
        raise_config_error 'Invalid campfire token'
      end

      unless room = campfire.find_room_by_name(data['room'])
        raise_config_error 'No such campfire room'
      end

      messages.each { |line| room.speak line }
      room.play "rimshot" if play_sound && room.respond_to?(:play)

      campfire.logout
    rescue Errno::ECONNREFUSED => boom
      raise_config_error "Connection refused- invalid campfire subdomain."
    end
  end

  attr_writer :campfire
  def campfire
    @campfire ||= Tinder::Campfire.new(data['subdomain'], :ssl => true)
  end
end
